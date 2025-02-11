package main

import (
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"crypto/sha512"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/tjfoc/gmsm/sm3"
)

// 计算所有哈希值的结果结构
type HashResults struct {
	MD5    string
	SHA1   string
	SHA256 string
	SHA512 string
	SM3    string
}

func main() {
	// 定义命令行参数
	dirPath := flag.String("h", ".", "要扫描的文件夹路径，默认为当前目录")
	flag.Parse()

	// 创建结果文件
	var resultFileName string
	if *dirPath == "." {
		resultFileName = "HashSum_result_current.csv"
	} else {
		resultFileName = "HashSum_result_" + filepath.Base(*dirPath) + ".csv"
	}

	// 获取绝对路径
	absResultPath, err := filepath.Abs(resultFileName)
	if err != nil {
		fmt.Printf("获取文件绝对路径失败: %v\n", err)
		return
	}

	resultFile, err := os.Create(resultFileName)
	if err != nil {
		fmt.Printf("创建结果文件失败: %v\n", err)
		return
	}
	defer resultFile.Close()

	// 写入表头
	header := "文件路径,MD5,SHA1,SHA256,SHA512,SM3\n"
	resultFile.WriteString(header)

	// 首先统计文件总数
	var totalFiles int
	filepath.Walk(*dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		if !info.IsDir() && !shouldSkipFile(info.Name()) {
			totalFiles++
		}
		return nil
	})

	// 显示开始处理的信息
	fmt.Printf("开始处理，共发现 %d 个文件...\n", totalFiles)

	// 处理计数器
	processedFiles := 0

	// 遍历文件夹
	err = filepath.Walk(*dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// 跳过文件夹和特定文件
		if info.IsDir() || shouldSkipFile(info.Name()) {
			return nil
		}

		// 更新进度
		processedFiles++
		progress := float64(processedFiles) / float64(totalFiles) * 100
		fmt.Printf("\r处理进度: [%-50s] %.1f%% (%d/%d)",
			strings.Repeat("=", int(progress/2))+">",
			progress,
			processedFiles,
			totalFiles,
		)

		// 计算文件的所有哈希值
		hashes, err := calculateFileHashes(path)
		if err != nil {
			fmt.Printf("\n计算文件 %s 的哈希值失败: %v\n", path, err)
			return nil
		}

		// 获取相对路径
		relPath, err := filepath.Rel(*dirPath, path)
		if err != nil {
			fmt.Printf("\n获取相对路径失败: %v\n", err)
			return nil
		}

		// 写入结果到文件
		result := fmt.Sprintf("%s,%s,%s,%s,%s,%s\n",
			strings.ReplaceAll(relPath, "\\", "/"),
			hashes.MD5,
			hashes.SHA1,
			hashes.SHA256,
			hashes.SHA512,
			hashes.SM3)

		_, err = resultFile.WriteString(result)
		if err != nil {
			fmt.Printf("\n写入结果失败: %v\n", err)
			return nil
		}

		return nil
	})

	fmt.Println() // 换行

	if err != nil {
		fmt.Printf("遍历文件夹失败: %v\n", err)
		return
	}

	fmt.Printf("\n哈希值计算完成！\n")
	fmt.Printf("结果文件保存在: %s\n\n", absResultPath)

	// 倒计时
	fmt.Println("程序将在10秒后自动退出...")
	for i := 10; i > 0; i-- {
		fmt.Printf("\r倒计时: %d 秒", i)
		time.Sleep(time.Second)
	}
	fmt.Println("\n再见！")
}

// 判断是否应该跳过该文件
func shouldSkipFile(filename string) bool {
	// 跳过结果文件和哈希校验文件
	return strings.HasPrefix(filename, "result_") ||
		strings.HasPrefix(filename, "HashSum")
}

// 计算文件的所有哈希值
func calculateFileHashes(filePath string) (HashResults, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return HashResults{}, err
	}
	defer file.Close()

	// 创建所有哈希对象
	md5Hash := md5.New()
	sha1Hash := sha1.New()
	sha256Hash := sha256.New()
	sha512Hash := sha512.New()
	sm3Hash := sm3.New()

	// 创建多重写入器
	multiWriter := io.MultiWriter(md5Hash, sha1Hash, sha256Hash, sha512Hash, sm3Hash)

	// 一次性读取文件并计算所有哈希值
	if _, err := io.Copy(multiWriter, file); err != nil {
		return HashResults{}, err
	}

	// 返回所有哈希结果
	return HashResults{
		MD5:    fmt.Sprintf("%x", md5Hash.Sum(nil)),
		SHA1:   fmt.Sprintf("%x", sha1Hash.Sum(nil)),
		SHA256: fmt.Sprintf("%x", sha256Hash.Sum(nil)),
		SHA512: fmt.Sprintf("%x", sha512Hash.Sum(nil)),
		SM3:    fmt.Sprintf("%x", sm3Hash.Sum(nil)),
	}, nil
}

#include <iostream>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <string>

using namespace cv;
using namespace std;

// 辅助函数：根据输入路径构建输出路径
string get_output_path(const string& input_path)
{
    // 查找最后一个路径分隔符的位置
    // 注意：在 Linux/Unix 系统中路径分隔符是 '/'
    size_t last_slash = input_path.find_last_of('/');

    if(last_slash == string::npos)
    {
        // 如果没有找到斜杠，说明文件在当前目录下
        // 将输出文件命名为：grayscale_输入文件名
        return "grayscale_" + input_path;
    }
    else
    {
        // 找到了斜杠，提取路径和文件名
        string dir_path  = input_path.substr(0, last_slash + 1);  // 路径（包含末尾的 /）
        string file_name = input_path.substr(last_slash + 1);     // 文件名

        // 查找文件扩展名的位置（例如 .jpg）
        size_t last_dot = file_name.find_last_of('.');

        string base_name;
        string extension;

        if(last_dot == string::npos)
        {
            // 没有扩展名
            base_name = file_name;
            extension = ".jpg";  // 默认使用 jpg 扩展名
        }
        else
        {
            // 有扩展名
            base_name = file_name.substr(0, last_dot);
            extension = file_name.substr(last_dot);
        }

        // 组合新的输出路径： 路径 + base_name + "_grayscale" + extension
        return dir_path + base_name + "_grayscale" + extension;
    }
}

int main(int argc, char** argv)
{
    if(argc != 2)
    {
        cerr << "用法: " << argv[0] << " <输入图片路径>" << endl;
        cerr << "示例: bazel run //main:opencv_demo -- -- path/to/input.jpg" << endl;
        return -1;
    }

    string image_path = argv[1];

    // 1. 读取图片
    Mat color_image = imread(image_path, IMREAD_COLOR);

    if(color_image.empty())
    {
        cerr << "错误: 无法打开或找不到图片: " << image_path << endl;
        return -1;
    }

    // 2. 转换成灰度图
    Mat grayscale_image;
    cvtColor(color_image, grayscale_image, COLOR_BGR2GRAY);

    // 3. 构建输出路径
    string output_path = get_output_path(image_path);

    // 4. 保存灰度图
    // 注意：由于是 bazel run，文件保存的位置是相对于 bazel 的执行目录，
    // 如果输入路径是相对路径，则输出也相对于 bazel 执行目录。
    bool success = imwrite(output_path, grayscale_image);

    if(!success)
    {
        cerr << "错误: 无法保存图片到: " << output_path << endl;
        // 可能是权限问题或路径不存在（如果路径的中间目录不存在）
        return -1;
    }

    cout << "灰度图已成功保存到: " << output_path << endl;

    return 0;
}
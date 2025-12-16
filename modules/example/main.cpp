// #include <iostream>
// #include <opencv2/opencv.hpp>

// int main() {
//   cv::Mat img(480, 640, CV_8UC3, cv::Scalar(0, 255, 0));
//   cv::putText(img, "Hello OpenCV + Bazel!", cv::Point(50, 240),
//               cv::FONT_HERSHEY_SIMPLEX, 1.0, cv::Scalar(0, 0, 255), 2);

//   cv::imshow("Test Window", img);
//   cv::waitKey(0);

//   std::cout << "OpenCV version: " << CV_VERSION << std::endl;
//   return 0;
// }

#include <iostream>
// #include <opencv2/core.hpp>  // 只包含 core 模块头文件
#include <opencv2/opencv.hpp>  // 注释掉，避免拉入其他模块

int main() {
  // 使用 core 模块创建一张 480x640 的 3 通道图像，初始为绿色背景
  cv::Mat img(480, 640, CV_8UC3, cv::Scalar(0, 255, 0));

  // core 模块支持基本的像素访问，这里演示修改中间一个像素为红色
  // （坐标 (320, 240) 为图像中心）
  img.at<cv::Vec3b>(240, 320) =
      cv::Vec3b(0, 0, 255);  // BGR 格式：蓝色0, 绿色0, 红色255

  // 输出图像基本信息（core 模块功能）
  std::cout << "Image size: " << img.size() << std::endl;
  std::cout << "Image channels: " << img.channels() << std::endl;
  std::cout << "Image type: " << img.type() << std::endl;
  std::cout << "Center pixel (B,G,R): "
            << static_cast<int>(img.at<cv::Vec3b>(240, 320)[0]) << ", "
            << static_cast<int>(img.at<cv::Vec3b>(240, 320)[1]) << ", "
            << static_cast<int>(img.at<cv::Vec3b>(240, 320)[2]) << std::endl;

  // 打印 OpenCV 版本（宏定义在 core 模块中）
  std::cout << "OpenCV version: " << CV_VERSION << std::endl;

  std::cout << "Core module test succeeded!" << std::endl;
  return 0;
}
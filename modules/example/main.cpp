#include <iostream>
#include <opencv2/calib3d.hpp>  // Required for calibration and 3D reconstruction features
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <string>
#include <vector>

using namespace cv;
using namespace std;

/**
 * Helper function: Constructs an output path based on the input path.
 * e.g., "data/test.jpg" with suffix "_gray" -> "data/test_gray.jpg"
 */
string get_output_path(const string& input_path, const string& suffix)
{
    size_t last_slash = input_path.find_last_of('/');
    string dir_path   = (last_slash == string::npos) ? "" : input_path.substr(0, last_slash + 1);
    string file_name =
        (last_slash == string::npos) ? input_path : input_path.substr(last_slash + 1);

    size_t last_dot  = file_name.find_last_of('.');
    string base_name = (last_dot == string::npos) ? file_name : file_name.substr(0, last_dot);
    string extension = (last_dot == string::npos) ? ".jpg" : file_name.substr(last_dot);

    return dir_path + base_name + suffix + extension;
}

/**
 * Feature 1: Converts the image to grayscale and saves it.
 * Modules used: imgproc, imgcodecs
 */
void process_to_grayscale(const Mat& input_image, const string& input_path)
{
    cout << "[Feature 1] Converting image to grayscale..." << endl;

    Mat grayscale_image;
    // Convert BGR color image to single-channel grayscale
    cvtColor(input_image, grayscale_image, COLOR_BGR2GRAY);

    string output_path = get_output_path(input_path, "_grayscale");

    if(imwrite(output_path, grayscale_image))
    {
        cout << "Success: Grayscale image saved to " << output_path << endl;
    }
    else
    {
        cerr << "Error: Could not save grayscale image." << endl;
    }
}

/**
 * Feature 2: Attempts to detect chessboard corners.
 * Module used: calib3d
 */
void detect_chessboard_features(const Mat& input_image, const string& input_path)
{
    cout << "\n[Feature 2] Calling calib3d module to detect chessboard..." << endl;

    Mat gray;
    if(input_image.channels() > 1)
    {
        cvtColor(input_image, gray, COLOR_BGR2GRAY);
    }
    else
    {
        gray = input_image;
    }

    // Set expected chessboard internal corners (columns x rows), e.g., 9x6
    Size            board_size(9, 6);
    vector<Point2f> corners;

    // Core function from the calib3d module
    bool found = findChessboardCorners(
        gray, board_size, corners, CALIB_CB_ADAPTIVE_THRESH | CALIB_CB_NORMALIZE_IMAGE);

    if(found)
    {
        cout << "Status: Success! Detected " << board_size.width << "x" << board_size.height
             << " chessboard." << endl;

        // Draw corners and save a preview in the same directory as the input
        Mat preview = input_image.clone();
        drawChessboardCorners(preview, board_size, corners, found);

        string chess_output = get_output_path(input_path, "_chessboard_preview");
        if(imwrite(chess_output, preview))
        {
            cout << "Status: Detection preview saved to " << chess_output << endl;
        }
        else
        {
            cerr << "Error: Could not save chessboard preview." << endl;
        }
    }
    else
    {
        cout << "Status: No 9x6 chessboard found." << endl;
        cout << "Note: If this function runs without errors, libopencv_calib3d.so is successfully "
                "linked."
             << endl;
    }
}

int main(int argc, char** argv)
{
    // Basic argument check
    if(argc != 2)
    {
        cerr << "Usage: " << argv[0] << " <input_image_path>" << endl;
        return -1;
    }

    string image_path = argv[1];

    // Load image
    Mat img = imread(image_path, IMREAD_COLOR);
    if(img.empty())
    {
        cerr << "Error: Could not load image. Check path: " << image_path << endl;
        return -1;
    }
    cout << "Loaded image: " << image_path << " [" << img.cols << "x" << img.rows << "]" << endl;

    // --- Execute feature functions ---

    // 1. Grayscale conversion logic
    process_to_grayscale(img, image_path);

    // 2. calib3d module logic (saving to the same directory)
    detect_chessboard_features(img, image_path);

    cout << "\nAll operations completed." << endl;
    return 0;
}
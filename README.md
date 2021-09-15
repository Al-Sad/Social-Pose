# The Social-Pose MATLAB Package V1.0 [1]
The material in this repository is provided to supplement the following paper:
M. Al-Sa'd, S. Kiranyaz, and M. Gabbouj, “A machine learning-based social distance estimation and crowd monitoring system for surveillance cameras”, *IEEE Transactions on Pattern Analysis and Machine Intelligence*, (2021).

The MATLAB scripts, functions, and datasets listed in this repository are used to produce results, and supporting figures illustrated in the paper.

## Demo Scripts:
The developed Social-Pose package contains the following demo scripts within its directory:
### Demo_1_person_detection.m
-   Description: This demo script produces the preliminary results that are depicted in Fig. 3 of the paper.
-   Process: It generates the pose estimations for the subjects in frame 1824 of the Epfl-Mpv 6p-c0 video sequence.
### Demo_2_localization.m
-   Description: This demo script produces the preliminary results that are depicted in Fig. 4a of the paper.
-   Process: It generates the subjects estimated ground positions in the image-pixel coordinates using the poses illustrated in Fig. 3. Besides, it compares the proposed localization strategy with the basic approach.
### Demo_3_top_view_transformation.m
-   Description: This demo script produces the preliminary results that are depicted in Fig. 4e of the paper.
-   Process: It transforms the subjects estimated ground positions from the image-pixel to the real-world coordinates resulting in a top-view depiction for the scene.
### Demo_4_smoothing_tracking.m
-   Description: This demo script produces the preliminary results that are depicted in Figs. 4b and 4f of the paper.
-   Process: It generates the smoothed and tracked ground positions in the image-pixel and real-world coordinates. Besides, it compares them to the original estimated ones.
### Demo_5_parameter_estimation.m
-   Description: This demo script produces the preliminary results that are depicted in Figs. 4c, 4d, 4g, and 4h of the paper.
-   Process: It yields the estimated inter-personal distances and instantaneous occupancy/crowd density maps in the image-pixel and real-world coordinates. Additionally, it demonstrates the detected social distance violations in both domains.
### Demo_6_system_integration.m
-   Description: This demo script produces the results that are depicted in Fig. 5 of the paper.
-   Process: It generates the proposed system example integrated video frames and dynamic top-view map using frames 1 to 1824 of the Epfl-Mpv 6p-c0 video sequence.
### Demo_7_results.m
-   Description: This demo script produces the results that are depicted in Fig. 6 and summarized in Table 2 of the paper.
-   Process: It generates the proposed system performance evaluation results in terms of PDR, localization relative error, accuracy, F1-score, VCR, SSIM, CORR, and IOU. In addition, it compares the proposed system with the basic approach.
### Demo_8_computational_time.m
-   Description: This demo script produces the results that are depicted in Fig. 7 of the paper.
-   Process: It generates the proposed system computational complexity analysis results in terms of frame rate grouped by the number of detected/tracked people in the scene.
## Main Scripts:
The developed Social-Pose package contains the following main scripts within its directory:
### Main_1_layout.m
-   Description: This main script generates the user selected region of interest (ROI) for the scene.
-   Process: The ROI is manually selected in the image-pixel domain and then transformed to the real-world coordinates. The ROIs in both domains are saved in the Layout folder under Data.
### Main_2_optimziation.m
-   Description: This main script optimizes the global nearest neighbor (GNN) tracking parameters.
-   Process: The optimization is initiated with the best-found solutions, executed for 500 iterations using the expected improvement plus acquisition function, and repeated five times for validation. The optimal parameters are then saved in the GNN Parameters folder under Data.
### Main_3_process.m
-   Description: This main script executes and evaluates the proposed social distance estimation and crowd monitoring system stages.
-   Process: It localizes the human subjects, transforms their positions to the real-world coordinates, smooths/tracks the measurements, recognizes social distance violations, and identifies overcrowded regions. Besides it evaluates the system in terms of PDR, localization relative error, accuracy, F1-score, VCR, SSIM, CORR, and IOU. The localization, top-view transformation, and tracking results are saved in the Ground Position Detections, Top View Positions, and Tracked Positions folders under Data, respectively. Additionally, the performance evaluations are saved in the Performance Evaluation folder under Data.
### Main_4_integrated_videos.m
-   Description: This main script produces the proposed system integrated video frames and dynamic top-view map.
-   Process: It generates the integrated results and saves them in video format in the Integrated Videos folder under Data. The integrated videos can be downloaded from: https://tuni-my.sharepoint.com/:f:/r/personal/mohammad_al-sad_tuni_fi/Documents/CVDI%20Project/First%20Round/Permenant%20DONT%20REMOVE/Integrated%20Videos?csf=1&web=1&e=fqzRKA.
### Main_5_computational_time.m
-   Description: This main script produces the proposed system computational analysis results.
-   Process: It generates the system processing frame rate with and without the smoothing/tracking stage and saves the results in the Computational Time folder under Data.
## Functions:
The developed Social-Pose package is comprised of the following MATLAB functions that are in specific folders within the Functions directory:
### Ground position detection
-   *basic_detector.m*: It detects the human subjects ground positions in the video sequence using the basic localization strategy; implementation of Eqs. (1) and (2).
-   *extended_detector.m*: It detects the human subjects ground positions in the video sequence using the proposed localization strategy; implementation of Algorithm 1. Besides, it yields the localization error flag as described by Eq. (3).
### Parameter estimation
-   *distance_matrix.m*: It computes the inter-personal distance matrix using the detected ground positions in the video sequence; implementation of Eq. (11).
-   *instantaneous_social_violations.m*: It recognizes and counts the number of social distance violations in a video frame; implementation of Eqs. (12), (13), and (19).
-   *social_violations.m*: It recognizes and counts the number of social distance violations in a complete video sequence.
-   *Gauss_spatial_density.m*: It generates a 2D symmetric Gaussian function with specific mean and resolution; implementation of Eq. (16).
-   *instantaneous_density_map.m*: It computes the occupancy/crowd density map for a video frame; implementation of Eqs. (15) and (18).
-   *density_map.m*: It computes the occupancy/crowd density map averaged across the complete video sequence; implementation of Eqs. (14) and (17).
-   *density_map_thresh.m*: It computes the threhsolded crowd density map averaged across the complete video sequence; implementation of Eq. (20).
### Performance evaluation
-   *count_people.m*: It counts the number of people using the detected positions in the complete video sequence.
-   *position_error.m*: It computes the localization relative error averaged across the complete video sequence; implementation of Eq. (22).
-   *class_perf_count.m*: It calculates the classification performance counts for binary and multi-class problems.
-   *class_perf.m*: It calculates the classification performance in terms of accuracy and F1-score for binary and multi-class problems; implementation of Eqs. (24) and (25).
### Plotting
-   *generate_poses.m*: It renders the estimated poses in a frame for plotting.
-   *prepare_tv_plot.m*: It prepares the top-view ground positions in the video sequence in accordance with the scene viewing perspective.
-   *tv_cam_plot.m*: It prepares the top-view real-world layout in accordance with the scene viewing perspective.
-   *tv_camera_poly.m*: It generates the camera top-view real-world polygon.
### Smoothing and tracking
-   *kalman_tracking.m*: The smoothing and tracking main function that employs the linear Kalman filter and the GNN tracker. It yields the smoothed/tracked top-view ground positions and velocities in the complete video sequence.

-   *detections.m*: It appends the top-view ground positions in the video sequence with measurement noise adaptively according to the localization error flag; implementation of Eq. (8).
-   *initialize_GNN.m*: It initializes the GNN tracker.
-   *get_data_id.m*: It extracts the Kalman filter state data (position or velocity) and IDs from the GNN tracker.
### Optimization
-   *kalman_opt_cost.m*: It calculates the smoothing and tracking total cost to be minimized.
-   *KF_distnace_cost.m*: It calculates the localization relative error summed across the complete video sequence.
-   *munkres.m*: The Munkres optimal assignment algorithm implementation by Yi Cao.
### TopView trasnformation
-   *uv2xy.m*: It transforms the ground positions in the complete video sequence from the image-pixel to the real-world coordinates.
-   *xy2uv.m*: It transforms the ground positions in the complete video sequence from the real-world to the image-pixel coordinates.
-   *xy2uv_mat.m*: It transforms the estimated density map in a video frame from the real world to the image-pixel coordinates.
## Data:
The developed Social-Pose package contains the following data that are in specific folders within Data directory:
### Computational Time:
This folder holds the system processing frame rate for each utilized video sequence.
### GNN Parameters:
This folder holds the optimal GNN parameters for each utilized video sequence.
### Ground Position Detections:
This folder holds the localization results using the proposed and basic approaches for each utilized video sequence.
### Integrated Videos:
It contains the output of the main script *Main_4_integrated_videos.m*; the proposed system integrated videos for each utilized video sequence. Alternatively, the videos can be downloaded from https://tuni-my.sharepoint.com/:f:/r/personal/mohammad_al-sad_tuni_fi/Documents/CVDI%20Project/First%20Round/Permenant%20DONT%20REMOVE/Integrated%20Videos?csf=1&web=1&e=fqzRKA.
### Layout:
This folder contains the user selected ROI in the image-pixel and real-world coordinates for each utilized video sequence.
### Performance Evaluation:
This folder holds the performance evaluations results in terms of PDR, localization relative error, accuracy, F1-score, VCR, SSIM, CORR, and IOU for each utilized video sequence.
### Top View Positions:
This folder includes the localization results in the real-world coordinates using the proposed and basic approaches for each utilized video sequence.
### Tracked Positions:
It holds the smoothing/tracking results in the image-pixel and real-world domains for each utilized video sequence.
## Database:
The developed Social-Pose package contains the following data that are in specific folders within Database directory:
### Annotation:
This folder holds the true localization data in the image-pixel and real-world domains for each utilized video sequence.
### Calibration:
It contains the homography matrix and image-to-real distance scale for each utilized video sequence.
### HumanJoints:
This folder contains the OpenPose estimated joints for each utilized video sequence.
### Videos:
It includes all utilized video sequences but sampled at 1 frame per second. Due to size limitation, the video sequences can be downloaded from https://tuni-my.sharepoint.com/:f:/g/personal/mohammad_al-sad_tuni_fi/Eku2N6IyUbpPtWGwDX5y16cBEykJ-hegdDcThbJQgpyt6g?e=N02Jub.

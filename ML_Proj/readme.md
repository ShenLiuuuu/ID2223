# README

## Project Overview
This project focuses on predicting the probability of delays and expected delay times for SL buses under various weather conditions. By combining real-time weather data with operational bus data, it enables users to make informed travel decisions, thereby improving travel efficiency and satisfaction.

### Key Objectives
1. Collect and process real-time meteorological data and SL bus operation data.
2. Predict the probability of SL bus delays based on current weather conditions.
3. Estimate expected delay times for SL buses under specific weather scenarios.
4. Build a user interface to display real-time weather conditions, delay probabilities, and expected delay times for SL bus users.

---

## File Structure

### 1. `dailyDataPipeline.py`
- Automates the daily data pipeline, including data download, processing, and cache cleanup.

### 2. `mergeData.ipynb` and `merge_data.ipynb`
- These Jupyter Notebooks are used for merging and analyzing data from different APIs, ensuring that both real-time and static data are properly integrated and verified.

### 3. `interaction.ipynb`
- Contains interactive steps for model training and prediction, allowing users to manually execute each step and observe results.

### 4. `XgisTruePredict.ipynb`
- Handles experimental prediction logic for specific conditions, such as certain routes or weather patterns.

### 5. `config.ini`
- Configuration file containing API keys, cache directories, and other adjustable parameters.

### 6. `getdata.py`
- Handles downloading real-time data from the public KoDa API. It supports several transit companies, including SL and Skånetrafiken.
- Supported real-time feeds include:
  - VehiclePositions
  - TripUpdates
  - ServiceAlerts

### 7. `getstatic.py`
- Responsible for downloading static GTFS data (such as routes and stops) from the public KoDa API.

### 8. `gtfs_realtime_pb2.py`
- A generated file using the `protobuf` compiler for parsing GTFS real-time data format.

### 9. `datautils.py`
- Contains utility functions for data processing, including:
  - Downloading and caching data
  - Cleaning redundant information
  - Loading and merging static data with real-time data

### 10. `requirements.txt`
- Lists all the required Python libraries and their versions to ensure a consistent development environment.

### 11. `output_csv/`
- Stores processed data files for further analysis or prediction.

### 12. `pykoda/`
- Core project module containing the main code for API interaction and data processing.

### 13. `merged_output.zip`
- Contains a compressed archive of the merged output data for offline analysis or model validation.

---

## Data Sources
1. **Weather Data**: Collected using the [Open-Meteo API](https://open-meteo.com/), which provides detailed weather data including precipitation, temperature, wind speed, and visibility.
2. **Bus Operation Data**: Retrieved from the [KoDa API provided by Trafiklab](https://www.trafiklab.se/api/trafiklab-apis/koda/), offering real-time information about bus schedules, live positions, and route deviations.

---

## Usage Instructions
1. Configure the `config.ini` file to ensure the correct API keys are provided.
2. Run `dailyDataPipeline.py` to automatically download and process daily data.
3. Use `mergeData.ipynb` or `interaction.ipynb` for data analysis and model training.
4. Run `XgisTruePredict.ipynb` to test the prediction model under specific conditions.

---

## Future Improvements
- Improve the accuracy of the prediction model, especially under extreme weather conditions.
- Enhance the user interface to provide more intuitive delay information.
- Expand support to include public transportation systems in other regions.

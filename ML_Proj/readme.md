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

### 2. `mergeData.ipynb`
- This Jupyter Notebooks are used for merging and analyzing data from traffic and weather APIs, ensuring that both real-time and static data are properly integrated and verified.

### 3. `interaction.ipynb`
- 需要补充 https://5db16d37b0788dbf2e.gradio.live

### 4. `XgisTruePredict.ipynb`
- Handles experimental prediction logic for specific conditions, such as certain routes or weather patterns.

### 5. `config.ini`
- Configuration file containing API keys, cache directories, and other adjustable parameters.

### 6. `requirements.txt`
- Lists all the required Python libraries and their versions to ensure a consistent development environment.

### 7. `pykoda/`
- Core project module containing the main code for API interaction and data processing.


---

## Data Sources
1. **Weather Data**: Collected using the [Open-Meteo API](https://open-meteo.com/), which provides detailed weather data including precipitation, temperature, wind speed, and visibility.
2. **Bus Operation Data**: Retrieved from the [KoDa API provided by Trafiklab](https://www.trafiklab.se/api/trafiklab-apis/koda/), offering real-time information about bus schedules, live positions, and route deviations.

---

## Usage Instructions
1. Configure the `config.ini` file to ensure the correct API keys are provided.
2. Install `requirements.txt`
3. Use `mergeData.ipynb` for data analysis and model training.
4. Run `XgisTruePredict.ipynb` to test the prediction model under specific conditions.
5. Configure Github Action and periodical run `dailyDataPipeline.py` to automatically download and process daily data.
6. `interaction.ipynb`需要补充

---

## 0.6.0 (April 5, 2022)

- Add initial set of harmonized terms (nsrr_*)
- Add additional AHI variables
- The CSV datasets generated from the SAS export is located here:
  - `\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\0.6.0\`

## 0.5.0 (December 16, 2020)

- Set some varibles as commonly used
- Remove identifier variable
- The CSV datasets generated from the SAS export is located here:
  - `\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\0.5.0\`

## 0.4.0 (November 18, 2019)

- Remove EEG spectral summary variables
- The CSV datasets generated from the SAS export is located here:
  - `\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\0.4.0\`
- **Gem Changes**
  - Updated to spout 1.0.0
  - Updated to Ruby 2.6.1

## 0.3.0 (March 21, 2017)

- Update `nsrrid` to better reflect it as primary identifier
- Incorporate Heart Rate Variability data for Visit 1
- Recode ages greater than 89 to 90 (deidentification)
- The CSV datasets generated from the SAS export is located here:
  - `\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\0.3.0\`

## 0.2.1 (January 19, 2016)

- **Gem Changes**
  - Updated to spout 0.11.0
  - Updated to Ruby 2.3.0

## 0.2.0 (January 14, 2016)

### Changes
- Add key demographic variables from BASELINE visit
- Remove `tudrinwk` variable
- Fix form JSON files to properly point to PDF files
- The CSV datasets generated from the SAS export is located here:
  - `\\rfa01\bwh-sleepepi-mros\nsrr-prep\_releases\0.2.0\`
    - `mros1-dataset-0.2.0.csv`
    - `mros2-dataset-0.2.0.csv`

## 0.1.0 (July 10, 2015)

### Changes
- The CSV datasets generated from the SAS export is located here:
  - `\\rfa01\bwh-sleepepi-mros\nsrr-prep\_releases\0.1.0\`
    - `mros1-dataset-0.1.0.csv`
    - `mros2-dataset-0.1.0.csv`
- **Gem Changes**
  - Use of Ruby 2.1.2 is now recommended
  - Updated to spout 0.10.2

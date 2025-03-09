-- Cleaning data in SQL Queries

SELECT*
FROM PortfolioProject.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE PortfolioProject.NashvilleHousing 
ADD COLUMN SaleDate_Formatted DATE;

UPDATE PortfolioProject.NashvilleHousing
SET SaleDate = SaleDate_Formatted
WHERE SaleDate_Formatted IS NOT NULL;

ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN SaleDate_Formatted;

SELECT*
FROM PortfolioProject.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Populate property address data. Carreful here, if the place is not null but just empty, we need to look after PropertyAddress = ''

SELECT*
FROM PortfolioProject.NashvilleHousing
-- WHERE PropertyAddress is null or PropertyAddress = '';
ORDER BY ParcelID

SELECT 
a.ParcelID,
a.PropertyAddress as Address_A,
b.ParcelID,
b.PropertyAddress as Address_B,
COALESCE (b.PropertyAddress) as CorrectedPropertyAddress
FROM PortfolioProject.NashvilleHousing a
JOIN PortfolioProject.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';

UPDATE PortfolioProject.NashvilleHousing a
JOIN PortfolioProject.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE (b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT * FROM PortfolioProject.NashvilleHousing 
WHERE PropertyAddress IS NULL OR PropertyAddress = '';

SELECT *
FROM PortfolioProject.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)) as Address
FROM PortfolioProject.NashvilleHousing;

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS PropertySplitAddress,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS PropertySplitCity
FROM PortfolioProject.NashvilleHousing;

ALTER TABLE PortfolioProject.NashvilleHousing
ADD COLUMN PropertySplitAddress VARCHAR(255), 
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE PortfolioProject.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress));

SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1) AS AddressPart1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS AddressPart2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS AddressPart3
FROM PortfolioProject.NashvilleHousing;

ALTER TABLE PortfolioProject.NashvilleHousing
ADD COLUMN OwnerSplitAddress VARCHAR(255), 
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE PortfolioProject.NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END AS SoldAsVacant
FROM PortfolioProject.NashvilleHousing

UPDATE PortfolioProject.NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
		
--------------------------------------------------------------------------------------------------------------------------

-- Remove duplicates

WITH RowNumCTE AS (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
                   ORDER BY UniqueID
               ) AS row_num
        FROM PortfolioProject.NashvilleHousing
    ) AS subquery
    WHERE row_num > 1
)

DELETE nh
FROM PortfolioProject.NashvilleHousing nh
JOIN RowNumCTE cte
ON nh.UniqueID = cte.UniqueID;

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select*
FROM PortfolioProject.NashvilleHousing nh

ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

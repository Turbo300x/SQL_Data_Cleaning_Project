
-- NASHVILLE HOUSING DATASET DATE CLEANING PROJECT.

---------------------------------------------------------------------------------------------------------------


-- (1) STANDARDIZE DATE FORMAT

SELECT *
FROM nashvilleHousing
ORDER BY ParcelID;

SELECT SaleDate, 
	   CONVERT(DATE, SaleDate) AS Date
FROM nashvilleHousing

ALTER TABLE nashvilleHousing
ADD SaleDate2 DATE;

UPDATE nashvilleHousing
SET SaleDate2 = CONVERT(DATE, SaleDate)


--SELECT
--	SaleDate2,
--	DATEPART(YYYY, SaleDate2) AS Year,
--	DATEPART(MM, SaleDate2) AS Month,
--	DATEPART(DD, SaleDate2) AS Day
--FROM nashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- (2) POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM nashvilleHousing
WHERE PropertyAddress IS NULL


SELECT *
FROM nashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT 
	nvh1.ParcelID, 
	nvh1.PropertyAddress, 
	nvh2.ParcelID, 
	nvh2.PropertyAddress,
	ISNULL(nvh1.PropertyAddress, nvh2.PropertyAddress)
FROM nashvilleHousing AS nvh1
JOIN nashvilleHousing AS nvh2
	ON nvh1.ParcelID = nvh2.ParcelID
	AND nvh1.[UniqueID ] <> nvh2.[UniqueID ]
WHERE nvh1.PropertyAddress IS NULL

UPDATE nvh1
SET PropertyAddress = ISNULL(nvh1.PropertyAddress, nvh2.PropertyAddress)
					  FROM nashvilleHousing AS nvh1
					  JOIN nashvilleHousing AS nvh2
						ON nvh1.ParcelID = nvh2.ParcelID
						AND nvh1.[UniqueID ] <> nvh2.[UniqueID ]
					  WHERE nvh1.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------

-- (3) BREAKING OUT PROPERTY ADDRESS AND OWNER ADDRESS INTO INDIVIDUAL COLUMNS.

-- Fisrtly i will split the property address column into individual columns (address, city)

SELECT PropertyAddress
FROM nashvilleHousing

SELECT 
	PropertyAddress,
	LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS PropertySplitAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertySplitCity
FROM nashvilleHousing

ALTER TABLE nashvilleHousing
ADD PropertySplitAddress NVARCHAR(225)

UPDATE nashvilleHousing
SET PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE nashvilleHousing
ADD PropertySplitCity NVARCHAR(225)

UPDATE nashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM nashvilleHousing

-- Secondly i will split the owner address column into individual columns (address, city, state)

SELECT OwnerAddress
FROM nashvilleHousing
ORDER BY ParcelID

SELECT 
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM nashvilleHousing
ORDER BY ParcelID

ALTER TABLE nashvilleHousing
ADD OwnerSplitAddress NVARCHAR(225)

UPDATE nashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashvilleHousing
ADD OwnerSplitCity NVARCHAR(225)

UPDATE nashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashvilleHousing
ADD OwnerSplitState NVARCHAR(225)

UPDATE nashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM nashvilleHousing
ORDER BY ParcelID

---------------------------------------------------------------------------------------------------------------

-- (4) CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

SELECT DISTINCT SoldAsVacant, COUNT(*)
FROM nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM nashvilleHousing


UPDATE nashvilleHousing
SET SoldAsVacant = CASE
					   WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   WHEN SoldAsVacant = 'N' THEN 'No'
					   ELSE SoldAsVacant
				   END



---------------------------------------------------------------------------------------------------------------

-- (5) REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT *,
	   ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY UniqueID
					) AS Row_Num

FROM nashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1

SELECT *
FROM nashvilleHousing
ORDER BY ParcelID



---------------------------------------------------------------------------------------------------------------

-- (6) DELETE UNUSED COLUMNS

SELECT *
FROM nashvilleHousing
ORDER BY ParcelID

ALTER TABLE nashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
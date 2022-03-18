-- Data
SELECT *
FROM DataCleaning.dbo.NashvilleHousing

-- Change sale date column to just date using alter
SELECT SaleDate, CONVERT(date, SaleDate) AS Date -- change it to date as shown
FROM DataCleaning.dbo.NashvilleHousing

ALTER TABLE DataCleaning.dbo.NashvilleHousing
ALTER COLUMN SaleDate date




-- Populate property address column by removing NULLs
SELECT *
FROM DataCleaning.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

			-- This shows there are addresses which are repeated: Due to multiple parcels --
SELECT ParcelID, PropertyAddress, COUNT(PropertyAddress) AS AddressCount
FROM DataCleaning.dbo.NashvilleHousing
GROUP BY ParcelID, PropertyAddress
HAVING COUNT(PropertyAddress) > 1

			-- Example where parcel ID is same but one address is missing
SELECT *
FROM DataCleaning.dbo.NashvilleHousing
WHERE ParcelID = '025 07 0 031.00'

			-- If parcel ID is same, populate with same address: This table shows the NULLS which should be filled in --
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS UodatedNULL
FROM DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

			-- updates the table with the ahove query --
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL




-- Breaking address into address, city, state, etc.
SELECT PropertyAddress
FROM DataCleaning.dbo.NashvilleHousing

			-- splits --
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM DataCleaning.dbo.NashvilleHousing

		-- Add it into the table as a column --
ALTER TABLE Datacleaning.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

ALTER TABLE Datacleaning.dbo.NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

		-- add the splits into the new columns -- 
UPDATE DataCleaning.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE DataCleaning.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




-- Split owner address into address, city and state: using different method
Select OwnerAddress
FROM DataCleaning.dbo.NashvilleHousing

			-- using parse: looks for full stops, therefore change commas to full stops --
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) -- parsename works from the end of the string i.e. -1 to 1 --
FROM DataCleaning.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM DataCleaning.dbo.NashvilleHousing

			-- add it into table -- 
ALTER TABLE Datacleaning.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

ALTER TABLE Datacleaning.dbo.NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

ALTER TABLE Datacleaning.dbo.NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

UPDATE Datacleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Datacleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Datacleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-- Change Y and N to Yes and No in SoldAsVacant column
SELECT SoldAsVacant, COUNT(SoldAsVacant) As Count
FROM DataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant

			-- statement to change --
SELECT SoldAsVacant,
CASE
	WHEN SoldASVacant = 'N' THEN 'No'
	WHEN SoldASVacant = 'Y' THEN 'Yes'
	ELSE SoldASVacant
END AS SoldAsVacantEdited
FROM DataCleaning.dbo.NashvilleHousing	

			-- update current column to new one --
UPDATE DataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldASVacant = 'N' THEN 'No'
	WHEN SoldASVacant = 'Y' THEN 'Yes'
	ELSE SoldASVacant
END




-- Removing duplicates

			-- this shows there are 103 duplicates that need to be removed
SELECT ParcelId, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, COUNT(*) AS Count
FROM DataCleaning.dbo.NashvilleHousing
GROUP BY ParcelId, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress
HAVING COUNT(*) > 1

			-- gets rid of duplicates by taking the MAX UNIQUE ID when grouping all the columns.
SELECT MAX(UniqueID), ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM DataCleaning.dbo.NashvilleHousing
GROUP BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState

			-- at this point I can use this table to create a new tabe without duplicates and use all the columns
DELETE FROM DataCleaning.dbo.NashvilleHousing
WHERE UniqueID NOT IN 
(
	SELECT MAX(UniqueID)
	FROM DataCleaning.dbo.NashvilleHousing
	GROUP BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
)




-- DELETE UNUSED COLUMNS
ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress











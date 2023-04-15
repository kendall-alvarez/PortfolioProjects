
/* Cleaning Data in SQL Queries, done on Azure */

SELECT *
From PortfolioProject.dbo.Nashville_Housing_Data

-----------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
From PortfolioProject.dbo.Nashville_Housing_Data
--Where PropertyAddress is null
order by ParcelID

SELECT N1.ParcelID, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, isnull(N1.PropertyAddress, N2.PropertyAddress)
From PortfolioProject..Nashville_Housing_Data N1
JOIN PortfolioProject..Nashville_Housing_Data N2
    on N1.ParcelID = N2.ParcelID
    and N1.[UniqueID] <> N2.[UniqueID]
Where N1.PropertyAddress is null

UPDATE N1
SET PropertyAddress = ISNULL(N1.PropertyAddress, N2.PropertyAddress)
From PortfolioProject..Nashville_Housing_Data N1
JOIN PortfolioProject..Nashville_Housing_Data N2
    on N1.ParcelID = N2.ParcelID
    and N1.[UniqueID] <> N2.[UniqueID]
Where N1.PropertyAddress is null

-----------------------------------------------------------------------------------------

-- Breaking out address into Individual Columns (Address, City, State)

SELECT PropertyAddress
From PortfolioProject.dbo.Nashville_Housing_Data


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject..Nashville_Housing_Data


ALTER TABLE Nashville_Housing_Data
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE Nashville_Housing_Data
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
From PortfolioProject.dbo.Nashville_Housing_Data




SELECT OwnerAddress
From PortfolioProject.dbo.Nashville_Housing_Data


SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
From PortfolioProject..Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE Nashville_Housing_Data
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE Nashville_Housing_Data
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

SELECT *
From PortfolioProject.dbo.Nashville_Housing_Data


-----------------------------------------------------------------------------------------

-- Change Y and N to Yes and no in "Sold as Vacant field"

Select Distinct(SoldAsVacant), Count(SoldasVacant)
FROM PortfolioProject..Nashville_Housing_Data
GROUP By SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       ELSE SoldAsVacant
       END


-----------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                    UniqueID
                    ) row_num


FROM PortfolioProject.dbo.Nashville_Housing_Data
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject.dbo.Nashville_Housing_Data






-----------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.Nashville_Housing_Data

ALTER TABLE PortfolioProject.dbo.Nashville_Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress




-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
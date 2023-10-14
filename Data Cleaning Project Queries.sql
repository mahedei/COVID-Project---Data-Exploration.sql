
---- Cleaning Data in SQL Queries.

Select *
From project. .NashvilleHousing;


-- Standardize Date Format.


Select saleDate, CONVERT(Date,SaleDate) as saleDateConverted
From project. .NashvilleHousing;

Update project. .NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);


-- If it doesn't Update then.

ALTER TABLE project. .NashvilleHousing
Add SaleDateConverted Date;

Update project. .NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);





-- Populate Property Address data.

Select *
From project. .NashvilleHousing
order by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project. .NashvilleHousing as a
JOIN project. .NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project. .NashvilleHousing as a
JOIN project. .NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;



-- Breaking out Address into Individual Columns (Address, City, State).


Select PropertyAddress
From project. .NashvilleHousing;
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From project. .NashvilleHousing;


ALTER TABLE project. .NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update project. .NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE project. .NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update project. .NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));




Select *
From project. .NashvilleHousing;





Select OwnerAddress
From project. .NashvilleHousing;


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project. .NashvilleHousing;



ALTER TABLE project. .NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update project. .NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE project. .NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update project. .NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);



ALTER TABLE project. .NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update project. .NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);



Select *
From project. .NashvilleHousing;



-- Change Y and N to Yes and No in "Sold as Vacant" field.


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From project. .NashvilleHousing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From project. .NashvilleHousing;


Update project. .NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;





-- Remove Duplicates.

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From project. .NashvilleHousing

)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;



Select *
From project. .NashvilleHousing;




-- Delete Unused Columns.


Select *
From project. .NashvilleHousing;


ALTER TABLE project. .NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;



----- update NULL values.

UPDATE project. .NashvilleHousing
SET OwnerName = CASE
    WHEN OwnerName IS NULL THEN 'Epmty'
    ELSE OwnerName 
END;

 
UPDATE project. .NashvilleHousing
SET
    Acreage = ISNULL(Acreage, 0),
    LandValue = ISNULL(LandValue, 0),
    BuildingValue = ISNULL(BuildingValue, 0),
    TotalValue = ISNULL(TotalValue, 0),
    YearBuilt = ISNULL(YearBuilt, 0),
    Bedrooms = ISNULL(Bedrooms, 0),
    FullBath = ISNULL(FullBath, 0),
    HalfBath = ISNULL(HalfBath, 0);


UPDATE project. .NashvilleHousing
SET OwnerSplitAddress = 'Empty',
    OwnerSplitCity = 'Empty',
    OwnerSplitState = 'Empty'
WHERE OwnerSplitAddress IS NULL
   OR OwnerSplitCity IS NULL
   OR OwnerSplitState IS NULL;


   Select *
From project. .NashvilleHousing;


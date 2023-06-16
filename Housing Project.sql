---------Cleaning Data in SQL Queries------------

select * 
from dbo.housing

---------------------------------------------------------------------------------------

----- Standardize Date Format--------

Select SaleDateConvert
from housing

Update housing
SET SaleDate = convert(date,SaleDate)

ALTER TABLE housing
ADD saleDateConvert date

update housing
SET SaleDateConvert = convert(date,SaleDate)

---------------------------------------------------------------------------------------


-----Populate Address Data------

select b.ParcelID,b.PropertyAddress,a.ParcelID,a.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housing a
JOIN dbo.housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housing a
JOIN dbo.housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------Breaking Address into Individual coloumns ( Address,state,city)-----------

select SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,len(propertyAddress)) AS Address
from dbo.housing

ALTER TABLE Housing
add  PropertySplitAddress NVARCHAR(500)

UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE Housing
ADD PropertySplitCity NVARCHAR(500)


UPDATE housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,len(propertyAddress))


select PARSENAME(REPLACE(OwnerAddress,',','.'), 3 ) AS Owner_Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2 )AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1 ) as State
from dbo.housing


ALTER TABLE Housing
ADD Owner_Address Nvarchar(300)

UPDATE Housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3 )

select * from housing


ALTER TABLE Housing
ADD Owner_City NVARCHAR(300)

UPDATE housing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2 )


ALTER TABLE Housing
ADD Owner_State NVARCHAR(300)

UPDATE housing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1 )

---------------------------------------------------------------------------------------

---Change Y and N to Yes and No in "Sold as Vacant" Field---------

select SoldAsVacant,
CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
from housing

UPDATE housing
SET SoldAsVacant = CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
---------------------------------------------------------------------------------------

---Rmove Duplicates------

WITH Duplicate_sales AS (
select *, 
ROW_NUMBER() OVER(PARTITION BY ParcelID,
                               PropertyAddress,
							   LegalReference,
							   SaleDate,
							   SalePrice
							   ORDER BY UniqueID) rowno
FROM housing
--order by ParcelID 
)
select * FROM Duplicate_sales
WHERE rowno > 1


---------------------------------------------------------------------------------------

-----Delete Unused Rows------------

ALTER TABLE Housing
DROP COLUMN SaleDate,OwnerAddress,PropertyAddress,TaxDistrict



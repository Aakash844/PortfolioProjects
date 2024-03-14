/*

Cleaning Data in SQL Queries

*/


select * 
from housingproject2..Sheet1$

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

	
select SaleDateConverted, convert(date,SaleDate)
from housingproject2..Sheet1$


update Sheet1$
set SaleDate = CONVERT(date,SaleDate)

-- If it doesn't Update properly	

ALTER TABLE	Sheet1$
Add SaleDateConverted Date;

update Sheet1$
set SaleDateConverted = CONVERT(date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
	
select *
from housingproject2..Sheet1$
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from housingproject2..Sheet1$ a
join housingproject2..Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

	
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from housingproject2..Sheet1$ a
join housingproject2..Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)	
	
		
select PropertyAddress
from housingproject2..Sheet1$
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address

from housingproject2..Sheet1$


ALTER TABLE	Sheet1$
Add PropertySplitAddress nvarchar(255);

update Sheet1$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE	Sheet1$
Add PropertySplitCity nvarchar(255);

update Sheet1$
set PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) 



	
select *
from housingproject2..Sheet1$


	
	
select OwnerAddress
from housingproject2..Sheet1$


	
select
PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
from housingproject2.dbo.Sheet1$



ALTER TABLE	Sheet1$
Add OwnerSplitAddress nvarchar(255);

update Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)


ALTER TABLE	Sheet1$
Add OwnerSplitCity nvarchar(255);

update Sheet1$
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.') ,2)


	
ALTER TABLE	Sheet1$
Add OwnerSplitState nvarchar(255);

update Sheet1$
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.') ,1)



select *
from housingproject2..Sheet1$


	
	
--------------------------------------------------------------------------------------------------------------------------
	

-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from housingproject2..Sheet1$
group by SoldAsVacant
order by 2



	
select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'YES'
	  when SoldAsVacant = 'N' then 'NO'
	  ELSE SoldAsVacant
	  end
from housingproject2..Sheet1$


UPDATE Sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	  when SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
	
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	partition by parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	
From housingproject2..Sheet1$
--ORDER by ParcelID
)
SELECT *
from RowNumCTE
where row_num > 1
--Order by PropertyAddress



select *
From housingproject2..Sheet1$




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


	
ALTER TABLE housingproject2..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE housingproject2..Sheet1$
DROP COLUMN SaleDate

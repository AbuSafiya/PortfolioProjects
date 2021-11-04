/* data Cleaning in SQL queries */

select *
from NasvilleHousingData


---------------------------------------------

--Standardize Date format

select SaleDateConverted, CONVERT(date, SaleDate)
from NasvilleHousingData


update NasvilleHousingData 
set SaleDate = CONVERT(date,SaleDate)


select SaleDate
from NasvilleHousingData


alter table NasvilleHousingData
add SaleDateConverted Date;


update NasvilleHousingData 
set SaleDateConverted = CONVERT(date,SaleDate)



---------------------------------------------------------

----Populate property Address


select *
from NasvilleHousingData
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NasvilleHousingData a
join NasvilleHousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NasvilleHousingData a
join NasvilleHousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------
--Breaking out Address into individual Columns (Address, City, State)

select distinct(PropertyAddress)
from NasvilleHousingData


select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address

from NasvilleHousingData



alter table NasvilleHousingData
add PropertySplitAddress Nvarchar(255);

update NasvilleHousingData 
set PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


alter table NasvilleHousingData
add PropertySplitCity nvarchar(255);

update NasvilleHousingData 
set PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))


select OwnerAddress
from NasvilleHousingData




select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3),
PARSENAME(Replace(OwnerAddress, ',', '.') , 2),
PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
from NasvilleHousingData

ALTER TABLE NasvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update NasvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NasvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update NasvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NasvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update NasvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
from NasvilleHousingData


----------------------------------------------------------------------------------------------------

---- Change Y and Y to YEs and No in "Sold as Vacant" field-------------------------

select distinct(SoldAsVacant), count(SoldAsVacant)
from NasvilleHousingData
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end

from NasvilleHousingData

update NasvilleHousingData
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end



	---------------------------------------------------

	----Remove duplicats-------------

with RowNumCTE as (
Select *,
ROW_NUMBER() over (partition by ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								order by
									UniqueID
								) row_num 

from NasvilleHousingData
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


select *
from NasvilleHousingData


------------------------------------------------------------------------------------

-------Delete Unused Columns

select *
from NasvilleHousingData

--alter table NasvilleHousingData
--drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table NasvilleHousingData
drop column SaleDate



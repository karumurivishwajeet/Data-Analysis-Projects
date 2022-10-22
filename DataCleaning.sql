Select *
from [Portfolio Project].dbo.Nashville_Housing$

-- Standardize Date Format
Select SaleDateConverted, Convert(Date, Saledate)
from [Portfolio Project].dbo.Nashville_Housing$

Update Nashville_Housing$
Set SaleDate = CONVERT(Date, Saledate)

Alter table Nashville_Housing$
Add SaleDateConverted Date;

Update Nashville_Housing$
Set SaleDateConverted = CONVERT(Date, Saledate)

-- Populate Property Address data

Select *
from [Portfolio Project].dbo.Nashville_Housing$
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress ,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].dbo.Nashville_Housing$ a
join [Portfolio Project].dbo.Nashville_Housing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].dbo.Nashville_Housing$ a
join [Portfolio Project].dbo.Nashville_Housing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from [Portfolio Project].dbo.Nashville_Housing$
-- where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from [Portfolio Project].dbo.Nashville_Housing$

Alter table Nashville_Housing$
Add PropertySplitAddress nvarchar(255);

Update Nashville_Housing$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

Alter table Nashville_Housing$
Add PropertySplitCity nvarchar(255);

Update Nashville_Housing$
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select *
from [Portfolio Project].dbo.Nashville_Housing$

Select OwnerAddress
from [Portfolio Project].dbo.Nashville_Housing$

Select
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from [Portfolio Project].dbo.Nashville_Housing$

Alter table Nashville_Housing$
Add OwnerSplitAddress nvarchar(255);

Update Nashville_Housing$
Set OwnerSplitAddress = parsename(Replace(OwnerAddress, ',','.'), 3) 

Alter table Nashville_Housing$
Add OwnerSplitCity nvarchar(255);

Update Nashville_Housing$
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

Alter table Nashville_Housing$
Add OwnerSplitState nvarchar(255);

Update Nashville_Housing$
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

Select *
from [Portfolio Project].dbo.Nashville_Housing$


-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
from [Portfolio Project].dbo.Nashville_Housing$
Group by SoldAsVacant
order by 2


Select SoldasVacant
, Case when soldasvacant = 'Y' Then 'Yes'
	   when soldasvacant = 'N' Then 'No'
	   else soldasvacant
	   end
from [Portfolio Project].dbo.Nashville_Housing$

update Nashville_Housing$
set SoldAsVacant = Case when soldasvacant = 'Y' Then 'Yes'
	   when soldasvacant = 'N' Then 'No'
	   else soldasvacant
	   end

-- Remove Duplicates

with RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 Saledate,
				 Saleprice,
				 LegalReference
				 order by uniqueId) row_num
from [Portfolio Project].dbo.Nashville_Housing$
--order by ParcelID
)
Select *
From RowNumCTE
where row_num>1
order by PropertyAddress




-- Delete Unused Columns

Select *
from [Portfolio Project].dbo.Nashville_Housing$

Alter table [Portfolio Project].dbo.Nashville_Housing$
Drop column OwnerAddress, Taxdistrict, PropertyAddress 

Alter table [Portfolio Project].dbo.Nashville_Housing$
Drop column SaleDate 












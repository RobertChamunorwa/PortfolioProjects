

--------------------------Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing


----------------------------Standardizing Data Format (Convert)


Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


--------------------------------------Populate Property Address Data 

-- Filling in the NULL Proeprty Address Data using the ParcelID

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where Propertyaddress is null
Order By ParcelID


Select a.ParcelID, a.Propertyaddress, b.ParcelID, b.Propertyaddress,ISNULL(a.Propertyaddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNull(a.Propertyaddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



----------------------------------Breaking Out Address into  individual Columns (adress, City, State) 


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
----Where Propertyaddress is null
--Order By ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress2  Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) 

Alter table NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 



----------------------Seperating the Owener  Breaking Down OwnerAddress Into Seperate Columns (OwnerSplitAddress, OwnerSplitCity, OwnerSplitState) 
Select OwnerAddress 
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress  Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState Nvarchar (255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)






----------------------------------------------Change Y and N to Yes and No in "Sold s Vacant" Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When  SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant 
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When  SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant 
	   END




------------------------------------------------Remove Duplicates

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	Partition By PArcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num




From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)

Delete
From RowNumCTE
Where Row_Num > 1
--Order by PropertyAddress

---------------------------------------Check if there are any duplicates 
With RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	Partition By PArcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num




From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)

Select *
From RowNumCTE
Where Row_Num > 1
Order by PropertyAddress




------------------------------Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate
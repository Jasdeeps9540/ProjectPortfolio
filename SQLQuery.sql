
--Cleaning Data using SQL--
--Nashville Housing Raw Data

Select *
from CleaningData..Nashville
---------------------------------------------------------------------------------------------------------------------------


--Standardise Date Format
--Remove the Time from Date

select SaleDate, Convert(date,SaleDate)
from CleaningData..Nashville

Alter TABLE Nashville
ADD SaleDateUpdate Date;

Update Nashville
SET SaleDateUpdate = Convert(date,SaleDate)

Select SaleDateUpdate
from CleaningData..Nashville
---------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data
--Addresses to NULL values based on ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from CleaningData..Nashville a
join CleaningData..Nashville b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from CleaningData..Nashville a
join CleaningData..Nashville b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

---------------------------------------------------------------------------------------------------------------------------

--Dividing Adresses into Columns (Address, City and State)

--Property Address

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City

from CleaningData..Nashville


Alter TABLE Nashville
ADD AddressUpdate Nvarchar(255);

Update Nashville
SET AddressUpdate = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter TABLE Nashville
ADD City Nvarchar(255);

Update Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

Select *
from Cleaningdata..Nashville
---------------------------------------------------------------------------------------------------------------------------

--Owner Address

select OwnerAddress
from CleaningData..Nashville

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from CleaningData..Nashville

Alter TABLE CleaningData..Nashville
ADD OwnerSplitAddress Nvarchar(255);

Alter TABLE Nashville
ADD OwnerSplitCity Nvarchar(255);

Alter TABLE Nashville
ADD OwnerSplitState Nvarchar(255);

Update CleaningData..Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update CleaningData..Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update CleaningData..Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * 
from Nashville
---------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldAsVacant

Select DISTINCT(SoldAsVacant),COUNT(SoldasVacant)
from CleaningData..Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant ='Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
from Nashville


Update Nashville
SET SoldAsVacant= CASE When SoldAsVacant ='Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End


Select DISTINCT(SoldAsVacant),COUNT(SoldasVacant)
from CleaningData..Nashville
Group by SoldAsVacant
Order by 2

---------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates
--Creating a Temp Table with CTE
With ROWNUMCTE AS (
Select * ,
	Row_Number() Over(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				SalePrice
				Order BY 
					UniqueID
				) row_num

from Nashville)

Delete
from ROWNUMCTE
where row_num > 1
---------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
from CleaningData..Nashville

ALTER Table CleaningData..Nashville
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

---------------------------------------------------------------------------------------------------------------------------


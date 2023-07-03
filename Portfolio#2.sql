-- standardize saledate coloumn

select saledate,convert(date,saledate) as saledatemodified
from portfolioproject.dbo.NasvilleHousing

select *
from portfolioproject.dbo.NasvilleHousing

select saledate,convert(date,saledate) as saledatemodified
from portfolioproject.dbo.NasvilleHousing

update NasvilleHousing
set saledate = convert(date,saledate)

--update function didnot work properly

alter table NasvilleHousing
add saledatemodified date;

update NasvilleHousing
set saledatemodified = convert(date,saledate)

select saledate,saledatemodified
from portfolioproject.dbo.NasvilleHousing


--populate property address data

select propertyaddress
from portfolioproject.dbo.NasvilleHousing
where propertyaddress is null


select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress) as newpropertyaddress
from portfolioproject.dbo.NasvilleHousing a
join portfolioproject.dbo.NasvilleHousing b
on a.parcelid= b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null

--Breaking out address into individual coloumns - address, city

select 
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as city
from portfolioproject.dbo.NasvilleHousing


alter table portfolioproject.dbo.NasvilleHousing
add propertysplitaddress nvarchar(255);

update portfolioproject.dbo.NasvilleHousing
set propertysplitaddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table portfolioproject.dbo.NasvilleHousing
add propertysplitcity nvarchar(255);

update portfolioproject.dbo.NasvilleHousing
set propertysplitcity = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

select*
from portfolioproject.dbo.NasvilleHousing


--Split owneraddress using parsename



Select owneraddress,

PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as ownerspilitaddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as ownerspilitcity,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as ownerspilitstate
From PortfolioProject.dbo.NasvilleHousing


alter table portfolioproject.dbo.NasvilleHousing
add ownersplitaddress nvarchar(255);

update portfolioproject.dbo.NasvilleHousing
set ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


alter table portfolioproject.dbo.NasvilleHousing
add ownersplitcity nvarchar(255);

update portfolioproject.dbo.NasvilleHousing
set ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


alter table portfolioproject.dbo.NasvilleHousing
add ownersplitstate nvarchar(255);

update portfolioproject.dbo.NasvilleHousing
set ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



select*
from portfolioproject.dbo.NasvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant),count(soldasvacant)
from portfolioproject.dbo.NasvilleHousing
group by soldasvacant
order by 2


update portfolioproject.dbo.NasvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
                        when soldasvacant = 'N' then 'No'
						else soldasvacant
						end

--Removing duplicates

with row_numcte as 
(
select *,
row_number() over(
partition by propertyaddress,
saledate,
saleprice,
legalreference,
parcelid
order by uniqueid)row_num
from portfolioproject.dbo.NasvilleHousing
)
select *
from row_numcte
Where row_num > 1
Order by PropertyAddress

delete 
from row_numcte
Where row_num > 1
--Order by PropertyAddress


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

From PortfolioProject.dbo.NasvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NasvilleHousing

--Removing unused coloumns

alter table PortfolioProject.dbo.NasvilleHousing
drop column propertyaddress,owneraddress,saledate,taxdistrict

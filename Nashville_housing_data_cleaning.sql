

--Standerdizing the date in SalesDate column
alter table housing_data
alter column saledate date

--Imputing null values in PropertyAddress column
/* by using self join we are going to impute null values in property address column using thr address having same ParcelID*/

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
from housing_data a
join housing_data b
on a.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
from housing_data a
join housing_data b
on a.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null

--Adding differnt column for Property Address and Property City

select propertyaddress, SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as property_address,
substring(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) as property_city
from housing_data

--adding address column
alter table housing_data
add Property_address nvarchar(255)

update housing_data
set property_address = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

--adding city column
alter table housing_data
add Property_city nvarchar(255)

update housing_data
set property_city = substring(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))


--Adding differnt columns(Address,City,State) from Owner Address
select PARSENAME(replace(owneraddress,',','.'),3) as [address],
PARSENAME(replace(owneraddress,',','.'),2) city,
PARSENAME(replace(owneraddress,',','.'),1) [state]
from housing_data

--adding owner address
alter table housing_data
add owner_address nvarchar(255)

update housing_data
set owner_address = PARSENAME(replace(owneraddress,',','.'),3)

--adding owner city
alter table housing_data
add owner_city nvarchar(255)

update housing_data
set owner_city = PARSENAME(replace(owneraddress,',','.'),2)

--adding owner state 
alter table housing_data
add owner_state nvarchar(255)

update housing_data
set owner_state = PARSENAME(replace(owneraddress,',','.'),1)


--Changing 'Y' to 'Yes' and 'N' to 'No' in SoldAsVacant field

select distinct(soldasvacant) ,count(soldasvacant) from housing_data
group by soldasvacant


update housing_data
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
						when soldasvacant = 'N' then 'No'
						else soldasvacant
						end

--Removing Duplicates

--getting the duplicate values
with row_numcte as(
select *, 
ROW_NUMBER() over(partition by 
				parcelid,
				propertyaddress,
				saledate,
				saleprice,
				legalreference
				order by parcelid) as row_num
from housing_data
)
select * from row_numcte where row_num > 1

--deleting the duplicate values
with row_numcte as(
select *, 
ROW_NUMBER() over(partition by 
				parcelid,
				propertyaddress,
				saledate,
				saleprice,
				legalreference
				order by parcelid) as row_num
from housing_data
)
delete from row_numcte where row_num > 1

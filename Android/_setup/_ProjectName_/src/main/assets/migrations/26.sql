ALTER TABLE Wishlist ADD COLUMN price_min REAL;
ALTER TABLE Wishlist ADD COLUMN price_max REAL;

ALTER TABLE RecentlyViewedItem ADD COLUMN price REAL;
ALTER TABLE RecentlyViewedItem ADD COLUMN price_min REAL;
ALTER TABLE RecentlyViewedItem ADD COLUMN price_max REAL;
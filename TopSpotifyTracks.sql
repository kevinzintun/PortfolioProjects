## TOP SPOTIFY TRACKS ##

-- Skills used: JOIN, Window Functions, CTEs, Creating Views

/* ** Dataset Description **
Two datasets were used for the analysis.

The first dataset (retrieved from Kaggle.com) contains audio statistics of the top 2000 tracks on Spotify from 2000-2019.
It contains 18 columns, each describing the track and its qualities.

The second dataset contains information on Rihanna's discography.
Columns include track title, writer, and album name.
The data is imported from Wikipedia and is cleaned using Microsoft Excel Power Query.
*/

-- Displays all the data
SELECT * 
FROM TopHitsSpotify;

-- Altered column name called 'key' to 'song_key' to resolve errors
ALTER TABLE TopHitsSpotify RENAME COLUMN `key` TO song_key;

 -- ** Top 5 Most Popular Songs **
 
 -- Shows top tracks ranked by their popularity scores
SELECT artist, song, year, popularity
FROM TopHitsSpotify
ORDER BY popularity DESC
LIMIT 5;

 -- ** Most Popular Genres **
 
 -- Lists the genres based on the number of occurrences in the dataset
 SELECT genre, COUNT(genre) AS num_songs
 FROM TopHitsSpotify
 GROUP BY genre
 ORDER BY COUNT(genre) DESC;
 
 -- ** Data for Word Cloud of Most Popular Genres **
 
 -- Lists each song's genre as a row in the view
 -- The data is then imported into Microsoft Excel Power Query for cleaning
CREATE VIEW mostpopulargenres AS
SELECT genre
FROM TopHitsSpotify;

-- ** Song Tempo Over Year **

-- Creates a view that shows the change in average song tempos over time
CREATE VIEW tempo_danceability AS
SELECT year, ROUND(AVG(tempo),2) AS average_tempo
FROM TopHitsSpotify
GROUP BY year
ORDER BY year ASC;

 -- ** Most Common Keys **
 
 -- Lists the most common musical keys in the dataset
 -- Using CTE to refine data as desired (i.e. remove 'no key detected' from the analysis)
WITH KEYS_CTE AS (	
SELECT 
	(CASE
		WHEN song_key = 0 THEN 'C'
		WHEN song_key = 1 THEN 'C#'
		WHEN song_key = 2 THEN 'D'
		WHEN song_key = 3 THEN 'D#'
		WHEN song_key = 4 THEN 'E'
		WHEN song_key = 5 THEN 'F'
		WHEN song_key = 6 THEN 'F#'
		WHEN song_key = 7 THEN 'G'
		WHEN song_key = 8 THEN 'G#'
		WHEN song_key = 9 THEN 'A'
		WHEN song_key = 10 THEN 'B'
		WHEN song_key = 11 THEN 'No key detected'
	END) AS song_key, 
	 COUNT(song_key) AS song_key_count, 
	 COUNT(CASE WHEN mode = 1 THEN 1 END) AS major_key_count,
	 COUNT(CASE WHEN mode = 0 THEN 1 END) AS minor_key_count
FROM TopHitsSpotify
GROUP BY song_key
ORDER BY song_key_count DESC
)
SELECT song_key, song_key_count, major_key_count, minor_key_count
FROM KEYS_CTE
WHERE song_key <> 'No key detected'; -- Removes the category 'No key detected' from the analysis

-- ******************** Artist Highlight: Rihanna ********************

-- ** Number 1 Artist With the Most Popular Songs **

-- Returns the artist with the largest number of tracks in the database
SELECT RANK() OVER(ORDER BY COUNT(artist) DESC) AS artist_rank, artist, COUNT(artist) AS num_songs
FROM TopHitsSpotify
GROUP BY artist
ORDER BY COUNT(artist) DESC
LIMIT 1;

-- ** Number of Top Songs **

-- Lists the number of songs the artist has in the database
SELECT artist, COUNT(song) AS song_count
FROM TopHitsSpotify
WHERE artist = 'Rihanna';

-- ** Total Minutes of Songs **

-- Adds the number of minutes of songs the top artist has
SELECT artist, FLOOR(SUM(duration_ms) / (1000 * 60)) % 60 as minutes
FROM TopHitsSpotify
WHERE artist = 'Rihanna'
GROUP BY artist;
    
-- ** Average Popularity Score **

-- Calculates the average popularity score of all the tracks of the artist
SELECT artist, AVG(popularity) AS average_pop
FROM TopHitsSpotify
WHERE artist = 'Rihanna'
GROUP BY artist;
     
-- ** Number of Albums **

-- Since album information was not available on the original database, another database was joined
SELECT t.artist, COUNT(DISTINCT a.album) as num_albums
FROM TopHitsSpotify AS t
LEFT JOIN rihanna_album_wiki_cleaned AS a 
-- Since we only need album information for tracks in the original database, a left join should suffice
	USING(song)
WHERE t.artist = 'Rihanna';
-- ******************************************************************
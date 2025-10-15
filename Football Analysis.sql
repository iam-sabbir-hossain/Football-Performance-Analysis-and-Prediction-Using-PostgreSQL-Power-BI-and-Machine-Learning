-- Table: appearances
CREATE TABLE appearances (
    appearance_id VARCHAR(50) PRIMARY KEY,  
    game_id VARCHAR(50) NOT NULL,          
    player_id VARCHAR(50) NOT NULL,       
    player_club_id VARCHAR(50),
    player_current_club_id VARCHAR(50),
    date DATE,
    player_name VARCHAR(500),
    competition_id VARCHAR(50),
    yellow_cards INT DEFAULT 0,
    red_cards INT DEFAULT 0,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    minutes_played INT DEFAULT 0
);


-- Table: club_games
CREATE TABLE club_games (
    game_id VARCHAR(50) NOT NULL,
    club_id VARCHAR(50),   
    own_goals INT,
    own_position INT,
    own_manager_name VARCHAR(255),
    opponent_id VARCHAR(50),
    opponent_goals INT,
    opponent_position INT,
    opponent_manager_name VARCHAR(255),
    hosting VARCHAR(50),
    is_win BOOLEAN,
    PRIMARY KEY (game_id, hosting)  
);

-- Table: clubs
CREATE TABLE clubs (
    club_id SERIAL PRIMARY KEY,
    club_code VARCHAR(50),
    name VARCHAR(255),
    domestic_competition_id VARCHAR(50),
    total_market_value BIGINT,
    squad_size INT,
    average_age NUMERIC(4,2),
    foreigners_number INT,
    foreigners_percentage NUMERIC(5,2),
    national_team_players INT,
    stadium_name VARCHAR(255),
    stadium_seats INT,
    net_transfer_record VARCHAR(100),
    coach_name VARCHAR(255),
    last_season VARCHAR(20),
    filename VARCHAR(255),
    url TEXT
);

-- Table: competitions
CREATE TABLE competitions (
    competition_id VARCHAR(50) PRIMARY KEY,  
    competition_code VARCHAR(50),
    name VARCHAR(255),
    sub_type VARCHAR(100),
    type VARCHAR(100),
    country_id VARCHAR(50),
    country_name VARCHAR(100),
    domestic_league_code VARCHAR(50),
    confederation VARCHAR(100),
    url TEXT,
    is_major_national_league BOOLEAN
);

-- Table: game_events
CREATE TABLE game_events (
    game_event_id VARCHAR(100) PRIMARY KEY,  
    date DATE,
    game_id VARCHAR(50),
    minute INT,
    type VARCHAR(100),
    club_id VARCHAR(50),
    player_id VARCHAR(50),
    description TEXT,
    player_in_id VARCHAR(50),
    player_assist_id VARCHAR(50)
);

-- Table: game_lineups
CREATE TABLE game_lineups (
    game_lineups_id VARCHAR(100) PRIMARY KEY,
    date DATE,
    game_id VARCHAR(100),
    player_id VARCHAR(100),
    club_id VARCHAR(100),
    player_name VARCHAR(255),
    type VARCHAR(50),
    position VARCHAR(50),
    number VARCHAR(100),   
    team_captain BOOLEAN
);

-- Table: games
CREATE TABLE games (
    game_id VARCHAR(100) PRIMARY KEY,
    competition_id VARCHAR(50),  
    season VARCHAR(20),
    round VARCHAR(50),
    date DATE,
    home_club_id VARCHAR(100),
    away_club_id VARCHAR(100),
    home_club_goals INT,
    away_club_goals INT,
    home_club_position INT,
    away_club_position INT,
    home_club_manager_name VARCHAR(255),
    away_club_manager_name VARCHAR(255),
    stadium VARCHAR(255),
    attendance INT,
    referee VARCHAR(255),
    url TEXT,
    home_club_formation VARCHAR(50),
    away_club_formation VARCHAR(50),
    home_club_name VARCHAR(255),
    away_club_name VARCHAR(255),
    aggregate VARCHAR(50),
    competition_type VARCHAR(100)
);

-- Table: player_valuations
CREATE TABLE player_valuations (
    player_id INT NOT NULL,
    date DATE NOT NULL,
    market_value_in_eur BIGINT,
    current_club_id INT,
    player_club_domestic_competition_id VARCHAR(50),
    PRIMARY KEY (player_id, date)
);

-- Table: players
CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    name VARCHAR(255),
    last_season VARCHAR(20),
    current_club_id INT,
    player_code VARCHAR(50),
    country_of_birth VARCHAR(100),
    city_of_birth VARCHAR(100),
    country_of_citizenship VARCHAR(100),
    date_of_birth DATE,
    sub_position VARCHAR(100),
    position VARCHAR(100),
    foot VARCHAR(20),
    height_in_cm INT,
    contract_expiration_date DATE,
    agent_name VARCHAR(255),
    image_url TEXT,
    url TEXT,
    current_club_domestic_competition_id VARCHAR(50),
    current_club_name VARCHAR(255),
    market_value_in_eur BIGINT,
    highest_market_value_in_eur BIGINT
);

-- Table: transfers
CREATE TABLE transfers (
    player_id VARCHAR(100),
    transfer_date DATE,
    transfer_season VARCHAR(20),
    from_club_id VARCHAR(100),
    to_club_id VARCHAR(100),
    from_club_name VARCHAR(255),
    to_club_name VARCHAR(255),
    transfer_fee VARCHAR(100),
    market_value_in_eur NUMERIC(20,3),
    player_name VARCHAR(255)
);

-- Drop table : 
DROP TABLE IF EXISTS transfers;
DROP TABLE IF EXISTS player_valuations;
DROP TABLE IF EXISTS appearances;
DROP TABLE IF EXISTS game_events;
DROP TABLE IF EXISTS game_lineups;
DROP TABLE IF EXISTS club_games;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS clubs;
DROP TABLE IF EXISTS competitions;

-- (1) Player Analysis:

-- Top scorers:
SELECT player_name, SUM(goals) AS total_goals
FROM appearances
GROUP BY player_id, player_name
ORDER BY total_goals DESC
LIMIT 10;

-- Most assists:
SELECT player_name, SUM(assists) AS total_assists
FROM appearances
GROUP BY player_id, player_name
ORDER BY total_assists DESC
LIMIT 10;

--Top 10 players by goals & assists combined (goal contribution):
SELECT 
    a.player_id,
    p.name AS player_name,
    SUM(a.goals + a.assists) AS goal_contributions
FROM appearances a
JOIN players p ON a.player_id::VARCHAR = p.player_id::VARCHAR
GROUP BY a.player_id, p.name
ORDER BY goal_contributions DESC
LIMIT 10;

--Most consistent players (goals per game):
SELECT 
    a.player_id,
    p.name AS player_name,
    COUNT(DISTINCT a.game_id) AS games_played,
    SUM(a.goals) AS total_goals,
    ROUND(SUM(a.goals)::NUMERIC / COUNT(DISTINCT a.game_id), 2) AS goals_per_game
FROM appearances a
JOIN players p ON a.player_id::VARCHAR = p.player_id::VARCHAR
GROUP BY a.player_id, p.name
HAVING COUNT(DISTINCT a.game_id) > 20
ORDER BY goals_per_game DESC
LIMIT 10;

-- Most yellow/red cards:
SELECT player_name, SUM(yellow_cards) AS total_yellow, SUM(red_cards) AS total_red
FROM appearances
GROUP BY player_id, player_name
ORDER BY total_red DESC, total_yellow DESC
LIMIT 10;

--(2) Club Analysis:

--Club total goals scored in all games:
SELECT c.name AS club_name, SUM(a.goals) AS total_goals
FROM appearances a
JOIN clubs c ON a.player_current_club_id = c.club_id::VARCHAR
GROUP BY c.name
ORDER BY total_goals DESC
LIMIT 10;

--Club win count:
SELECT c.name AS club_name, COUNT(*) AS wins
FROM club_games cg
JOIN clubs c ON cg.club_id::INT = c.club_id   
WHERE cg.is_win = TRUE
GROUP BY c.name
ORDER BY wins DESC
LIMIT 10;

--Average player market value per club
SELECT p.current_club_id, c.name, AVG(p.market_value_in_eur) AS avg_market_value
FROM players p
JOIN clubs c ON p.current_club_id = c.club_id
GROUP BY p.current_club_id, c.name
ORDER BY avg_market_value DESC
LIMIT 10;

--(3)Competition Analysis:

--Most popular competitions by average attendance:
SELECT 
    comp.name AS competition_name,
    ROUND(AVG(g.attendance),0) AS avg_attendance
FROM games g
JOIN competitions comp ON g.competition_id = comp.competition_id
WHERE g.attendance IS NOT NULL
GROUP BY comp.name
ORDER BY avg_attendance DESC
LIMIT 10;

--Competitions with the highest scoring games (avg goals per match):
SELECT 
    comp.name AS competition_name,
    ROUND(AVG(g.home_club_goals + g.away_club_goals),2) AS avg_goals_per_game
FROM games g
JOIN competitions comp ON g.competition_id = comp.competition_id
GROUP BY comp.name
ORDER BY avg_goals_per_game DESC
LIMIT 10;

--Total goals per competition:
SELECT g.competition_id, c.name AS competition_name, SUM(a.goals) AS total_goals
FROM games g
JOIN appearances a ON g.game_id = a.game_id
JOIN competitions c ON g.competition_id = c.competition_id
GROUP BY g.competition_id, c.name
ORDER BY total_goals DESC;

--Most competitive leagues (most games):
SELECT 
    g.competition_id,
    c.name AS competition_name,
    COUNT(*) AS total_games
FROM games g
JOIN competitions c ON g.competition_id = c.competition_id
GROUP BY g.competition_id, c.name
ORDER BY total_games DESC
LIMIT 10;

--(4)Transfers & Market Analysis:

--Players with highest transfer fees:
SELECT player_name, transfer_fee, from_club_name, to_club_name, transfer_date
FROM transfers
WHERE transfer_fee IS NOT NULL
ORDER BY CAST(transfer_fee AS NUMERIC) DESC
LIMIT 10;

--Clubs that spent the most on transfers:
SELECT 
    to_club_name,
    COUNT(*) AS transfers_in,
    SUM(t.market_value_in_eur) AS total_spent
FROM transfers t
WHERE t.market_value_in_eur IS NOT NULL
GROUP BY to_club_name
ORDER BY total_spent DESC
LIMIT 10;

--Average player market value per season:
SELECT transfer_season, AVG(market_value_in_eur) AS avg_value
FROM transfers
WHERE market_value_in_eur IS NOT NULL
GROUP BY transfer_season
ORDER BY transfer_season;

--Most active players in transfer market:
SELECT player_name, COUNT(*) AS total_transfers
FROM transfers
GROUP BY player_name
ORDER BY total_transfers DESC
LIMIT 10;

--(5)Game Analysis:

--Average attendance per stadium:
SELECT stadium, AVG(attendance) AS avg_attendance
FROM games
WHERE attendance IS NOT NULL
GROUP BY stadium
ORDER BY avg_attendance DESC
LIMIT 10;

--Players participating in most games:
SELECT player_id, player_name, COUNT(*) AS total_appearances
FROM appearances
GROUP BY player_id, player_name
ORDER BY total_appearances DESC
LIMIT 10;

--Referees with most games officiated:
SELECT 
    referee,
    COUNT(*) AS games_officiated
FROM games
WHERE referee IS NOT NULL
GROUP BY referee
ORDER BY games_officiated DESC
LIMIT 10;

--(6)Advanced Analysis:

--Top 5 players per competition by goals:
SELECT a.player_id, a.player_name, g.competition_id, SUM(a.goals) AS goals
FROM appearances a
JOIN games g ON a.game_id = g.game_id
GROUP BY a.player_id, a.player_name, g.competition_id
ORDER BY g.competition_id, goals DESC
LIMIT 5;

-- Top 10 clubs by average wins per season
WITH club_wins_per_season AS (
    SELECT 
        c.name AS club_name,
        g.season,
        COUNT(*) AS wins
    FROM club_games cg
    JOIN clubs c ON cg.club_id::INT = c.club_id   -- casting fix
    JOIN games g ON cg.game_id = g.game_id
    WHERE cg.is_win = TRUE
    GROUP BY c.name, g.season
)
SELECT 
    club_name,
    ROUND(AVG(wins), 2) AS avg_wins_per_season
FROM club_wins_per_season
GROUP BY club_name
ORDER BY avg_wins_per_season DESC
LIMIT 10;

--Player market value vs performance (goals):
SELECT p.name, SUM(a.goals) AS total_goals, p.market_value_in_eur
FROM appearances a
JOIN players p ON a.player_id = p.player_id::VARCHAR
GROUP BY p.name, p.market_value_in_eur
ORDER BY total_goals DESC
LIMIT 10;



















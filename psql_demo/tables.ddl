CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE auth.Device (
    id    VARCHAR(255) PRIMARY KEY
);

CREATE TABLE auth.Challenge (
    device_id   VARCHAR(255),
    challenge   VARCHAR(255),
    response    VARCHAR(255),
    PRIMARY KEY (device_id, challenge),
    FOREIGN KEY (device_id) REFERENCES auth.Device(id)
);

-- Insert data into Device table (combined inserts)
INSERT INTO auth.Device (id) VALUES ('device001'), ('device002');

-- Insert data into Challenge table (combined inserts)
INSERT INTO auth.Challenge (device_id, challenge, response) VALUES 
    ('device001', 'login', 'success'), 
    ('device001', 'request', 'response'), 
    ('device002', 'status_check', 'online');

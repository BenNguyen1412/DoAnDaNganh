-- Tạo database
DROP DATABASE IF EXISTS do_an;
CREATE DATABASE do_an;
USE do_an;

-- Bảng 1: dong_co
CREATE TABLE dong_co (
    Ki_hieu VARCHAR(10) PRIMARY KEY,
    So_vong_quay INT NOT NULL,
    Loai_dong_co CHAR(10) NOT NULL,
    Cong_suat FLOAT NOT NULL,
    cos_phi FLOAT NOT NULL,
    TK_TD FLOAT NOT NULL,
    Khoi_Luong FLOAT NOT NULL
);

INSERT INTO dong_co (Ki_hieu, So_vong_quay, Loai_dong_co, Cong_suat, cos_phi, TK_TD, Khoi_Luong)  
VALUES 
    ('DK 42-2', 3000, 'DK', 2.8, 0.88, 1.9, 47),
    ('K112M2', 3000, 'K', 3.0, 0.0, 2.5, 42),
    ('4A90L2Y3', 3000, '4A', 3.0, 0.88, 2.0, 28.7),
    ('DK 52-4', 1500, 'DK', 7.0, 0.85, 1.5, 104),
    ('K160S4', 1500, 'K', 7.5, 0.86, 2.2, 94),
    ('4A132S4Y3', 1500, '4A', 7.5, 0.86, 2.0, 77);

-- Bảng 2: TST
CREATE TABLE TST(
    u_h INT NOT NULL,
    u_1 FLOAT NOT NULL,
    u_2 FLOAT NOT NULL
);

INSERT INTO TST (u_h, u_1, u_2)
VALUES
    (6 , 2.73, 2.2),
    (8 , 3.3, 2.42),
    (10 ,3.83, 2.61),
    (12 , 4.32, 2.78),
    (14 , 4.79, 2.92),
    (16 , 5.23 , 3.06),
    (18 , 5.66 , 3.18),
    (20 , 6.07 , 3.29),
    (22 , 6.48 , 3.39),
    (24 , 6.86 , 3.5),
    (26 , 7.23 , 3.59),
    (28 , 7.6 , 3.68),
    (30 , 7.96, 3.37);

-- Bảng 3: calculation_history
CREATE TABLE calculation_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    calculation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    input_params JSON NOT NULL,
    motor_info JSON NOT NULL,
    calculation_results JSON NOT NULL,
    motor_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

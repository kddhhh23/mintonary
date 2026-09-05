-- Mintonary 스키마
-- ENUM 대신 VARCHAR + COMMENT 사용 (JPA @Enumerated(EnumType.STRING) 대응)

-- =========================
-- 마스터 테이블 (제품 정보)
-- =========================

CREATE TABLE racket_model (
    id     BIGINT       NOT NULL AUTO_INCREMENT,
    brand  VARCHAR(50)  NOT NULL,
    series VARCHAR(50)  NULL,
    name   VARCHAR(100) NOT NULL,
    weight VARCHAR(10)  NULL COMMENT 'U2, U3, U4, U5, U6 (2U~6U, Java enum이 숫자로 시작 불가)',
    balance VARCHAR(50) NULL,
    flex   VARCHAR(50)  NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE shoe_model (
    id    BIGINT       NOT NULL AUTO_INCREMENT,
    brand VARCHAR(50)  NOT NULL,
    name  VARCHAR(100) NOT NULL,
    width VARCHAR(20)  NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE string_model (
    id    BIGINT       NOT NULL AUTO_INCREMENT,
    brand VARCHAR(100) NULL,
    name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE grip_model (
    id    BIGINT       NOT NULL AUTO_INCREMENT,
    brand VARCHAR(100) NULL,
    name  VARCHAR(100) NOT NULL,
    type  VARCHAR(20)  NULL COMMENT 'OVER, TOWEL, CUSHION',
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- =========================
-- 회원
-- =========================

CREATE TABLE member (
    id             BIGINT       NOT NULL AUTO_INCREMENT,
    login_id       VARCHAR(30)  NOT NULL,
    password       VARCHAR(255) NOT NULL,
    email          VARCHAR(100) NULL,
    email_verified BOOLEAN      NOT NULL DEFAULT FALSE,
    nickname       VARCHAR(20)  NOT NULL,
    birth_date     DATE         NULL,
    gender         VARCHAR(10)  NULL COMMENT 'MALE, FEMALE',
    local_class    VARCHAR(20)  NULL COMMENT 'S, A, B, C, D, E, F',
    national_class VARCHAR(20)  NULL COMMENT 'S, A, B, C, D, E, F',
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at     DATETIME     NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_member_login_id (login_id),
    UNIQUE KEY uk_member_nickname (nickname),
    UNIQUE KEY uk_member_email (email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- =========================
-- 내 장비
-- =========================

CREATE TABLE equipment (
    id            BIGINT      NOT NULL AUTO_INCREMENT,
    member_id     BIGINT      NOT NULL,
    type          VARCHAR(20) NOT NULL COMMENT 'RACKET, SHOE',
    purchase_date DATE        NULL,
    price         INT         NULL,
    memo          VARCHAR(500) NULL,
    retired_at    DATE        NULL COMMENT '방출일, NULL이면 사용 중',
    created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_equipment_member FOREIGN KEY (member_id) REFERENCES member (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE my_racket (
    id                BIGINT NOT NULL AUTO_INCREMENT,
    equipment_id      BIGINT NOT NULL,
    racket_model_id   BIGINT NOT NULL,
    string_alarm_date DATE   NULL COMMENT '다음 스트링 교체 알림 날짜',
    PRIMARY KEY (id),
    UNIQUE KEY uk_my_racket_equipment (equipment_id),
    CONSTRAINT fk_my_racket_equipment FOREIGN KEY (equipment_id) REFERENCES equipment (id),
    CONSTRAINT fk_my_racket_model FOREIGN KEY (racket_model_id) REFERENCES racket_model (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE my_shoe (
    id            BIGINT NOT NULL AUTO_INCREMENT,
    equipment_id  BIGINT NOT NULL,
    shoe_model_id BIGINT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_my_shoe_equipment (equipment_id),
    CONSTRAINT fk_my_shoe_equipment FOREIGN KEY (equipment_id) REFERENCES equipment (id),
    CONSTRAINT fk_my_shoe_model FOREIGN KEY (shoe_model_id) REFERENCES shoe_model (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- =========================
-- 라켓 관리 이력
-- =========================

CREATE TABLE racket_string_history (
    id              BIGINT       NOT NULL AUTO_INCREMENT,
    my_racket_id    BIGINT       NOT NULL,
    string_model_id BIGINT       NOT NULL,
    tension         INT          NULL,
    strung_at       DATE         NOT NULL,
    memo            VARCHAR(500) NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_string_history_racket FOREIGN KEY (my_racket_id) REFERENCES my_racket (id),
    CONSTRAINT fk_string_history_model FOREIGN KEY (string_model_id) REFERENCES string_model (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE racket_grip_history (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    my_racket_id  BIGINT       NOT NULL,
    grip_model_id BIGINT       NOT NULL,
    wrapped_at    DATE         NOT NULL,
    memo          VARCHAR(500) NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_grip_history_racket FOREIGN KEY (my_racket_id) REFERENCES my_racket (id),
    CONSTRAINT fk_grip_history_model FOREIGN KEY (grip_model_id) REFERENCES grip_model (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- =========================
-- 운동 기록
-- =========================

CREATE TABLE workout_record (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    member_id   BIGINT       NOT NULL,
    record_date DATE         NOT NULL,
    type        VARCHAR(20)  NOT NULL COMMENT 'GENERAL, LESSON, TOURNAMENT',
    title       VARCHAR(100) NOT NULL,
    place       VARCHAR(100) NULL,
    coach       VARCHAR(50)  NULL,
    result      VARCHAR(100) NULL COMMENT '대회 결과 (예: 준우승, 조별 예선 탈락)',
    memo        VARCHAR(500) NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_workout_record_member FOREIGN KEY (member_id) REFERENCES member (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- =========================
-- 지출 기록
-- =========================

CREATE TABLE expense (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    member_id    BIGINT       NOT NULL,
    expense_date DATE         NOT NULL,
    category     VARCHAR(20)  NOT NULL COMMENT 'COURT, LESSON, SHUTTLECOCK, EQUIPMENT, TOURNAMENT, OTHER',
    title        VARCHAR(100) NOT NULL,
    amount       INT          NOT NULL,
    memo         VARCHAR(500) NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_expense_member_date (member_id, expense_date),
    CONSTRAINT fk_expense_member FOREIGN KEY (member_id) REFERENCES member (id),
    CONSTRAINT chk_expense_amount CHECK (amount > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

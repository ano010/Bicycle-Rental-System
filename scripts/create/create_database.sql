-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema brs
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema brs
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `brs`;
CREATE SCHEMA IF NOT EXISTS `brs` DEFAULT CHARACTER SET utf8 ;
USE `brs` ;

-- -----------------------------------------------------
-- Table `brs`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`user` (
  `nic` VARCHAR(10) NOT NULL,
  `fname` VARCHAR(50) NOT NULL,
  `lname` VARCHAR(50) NOT NULL,
  `dob` DATE NOT NULL,
  `sex` ENUM('M', 'F') NOT NULL,
  `phone` INT(10) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`nic`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`store_manager`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`store_manager` (
  `nic` VARCHAR(10) NOT NULL,
  `from_date` DATE NOT NULL,
  `to_date` DATE NULL,
  PRIMARY KEY (`nic`),
  INDEX `fk_store_manager_user1_idx` (`nic` ASC) VISIBLE,
  CONSTRAINT `fk_store_manager_user1`
    FOREIGN KEY (`nic`)
    REFERENCES `brs`.`user` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`store`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`store` (
  `id` INT(3) NOT NULL AUTO_INCREMENT,
  `location` VARCHAR(50) NOT NULL,
  `number_of_bicycles` INT(5) NOT NULL DEFAULT 0,
  `manager` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_store_store_manager1_idx` (`manager` ASC) VISIBLE,
  CONSTRAINT `fk_store_store_manager1`
    FOREIGN KEY (`manager`)
    REFERENCES `brs`.`store_manager` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`store_cashier`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`store_cashier` (
  `nic` VARCHAR(10) NOT NULL,
  `from_date` DATE NOT NULL,
  `to_date` DATE NOT NULL,
  `store_id` INT(3) NOT NULL,
  PRIMARY KEY (`nic`),
  INDEX `fk_store_cashier_user1_idx` (`nic` ASC) VISIBLE,
  INDEX `fk_store_cashier_store1_idx` (`store_id` ASC) VISIBLE,
  CONSTRAINT `fk_store_cashier_user1`
    FOREIGN KEY (`nic`)
    REFERENCES `brs`.`user` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_store_cashier_store1`
    FOREIGN KEY (`store_id`)
    REFERENCES `brs`.`store` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`customer` (
  `nic` VARCHAR(10) NOT NULL,
  `registrationDate` DATE NOT NULL,
  `lastRentalDate` DATE NULL,
  PRIMARY KEY (`nic`),
  INDEX `fk_customer_user1_idx` (`nic` ASC) VISIBLE,
  CONSTRAINT `fk_customer_user1`
    FOREIGN KEY (`nic`)
    REFERENCES `brs`.`user` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`bicycle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`bicycle` (
  `id` INT(10) NOT NULL,
  `model` VARCHAR(50) NULL,
  `status` VARCHAR(45) NOT NULL,
  `store_id` INT(3) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_bicycle_store1_idx` (`store_id` ASC) VISIBLE,
  CONSTRAINT `fk_bicycle_store1`
    FOREIGN KEY (`store_id`)
    REFERENCES `brs`.`store` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`payment_status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`payment_status` (
  `id` INT(1) NOT NULL,
  `status` VARCHAR(10) NOT NULL,
  `description` VARCHAR(255) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`rental`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`rental` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `rentalDate` DATE NULL,
  `returnDate` DATE NULL,
  `dailyRentalDate` FLOAT NULL,
  `rent_from` INT(3) NULL,
  `return_to` INT(3) NULL,
  `bicycle_id` INT(10) NOT NULL,
  `payment_status_id` INT(1) NOT NULL,
  `customer_nic` VARCHAR(10) NOT NULL,
  `store_cashier_nic` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_rental_store1_idx` (`rent_from` ASC) VISIBLE,
  INDEX `fk_rental_store2_idx` (`return_to` ASC) VISIBLE,
  INDEX `fk_rental_bicycle1_idx` (`bicycle_id` ASC) VISIBLE,
  INDEX `fk_rental_payment_status1_idx` (`payment_status_id` ASC) VISIBLE,
  INDEX `fk_rental_customer1_idx` (`customer_nic` ASC) VISIBLE,
  INDEX `fk_rental_store_cashier1_idx` (`store_cashier_nic` ASC) VISIBLE,
  CONSTRAINT `fk_rental_store1`
    FOREIGN KEY (`rent_from`)
    REFERENCES `brs`.`store` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rental_store2`
    FOREIGN KEY (`return_to`)
    REFERENCES `brs`.`store` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rental_bicycle1`
    FOREIGN KEY (`bicycle_id`)
    REFERENCES `brs`.`bicycle` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rental_payment_status1`
    FOREIGN KEY (`payment_status_id`)
    REFERENCES `brs`.`payment_status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rental_customer1`
    FOREIGN KEY (`customer_nic`)
    REFERENCES `brs`.`customer` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rental_store_cashier1`
    FOREIGN KEY (`store_cashier_nic`)
    REFERENCES `brs`.`store_cashier` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `brs`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `brs`.`address` (
  `user_nic` VARCHAR(10) NOT NULL,
  `street` VARCHAR(255) NULL,
  `city` VARCHAR(50) NULL,
  `district` VARCHAR(50) NULL,
  `country` VARCHAR(50) NULL,
  PRIMARY KEY (`user_nic`),
  INDEX `fk_adress_user1_idx` (`user_nic` ASC) VISIBLE,
  CONSTRAINT `fk_adress_user1`
    FOREIGN KEY (`user_nic`)
    REFERENCES `brs`.`user` (`nic`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
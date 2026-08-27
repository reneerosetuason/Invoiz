-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: invoizdb
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `invoizdb`
--

/*!40000 DROP DATABASE IF EXISTS `invoizdb`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `invoizdb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `invoizdb`;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `recipient_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `barangay` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_addresses_buyer` (`buyer_id`),
  CONSTRAINT `fk_addresses_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,2,'Juan Dela Cruz','09171112233','123 Mabini St','Brgy. San Isidro','Majayjay','Laguna','4005',1,'2026-08-14 10:41:37','2026-08-14 10:41:37'),(2,3,'Renee Rose Tuason','09307570755','Cailles Street','Maytalang 1','Lumban','Laguna','4014',1,'2026-08-14 11:09:58','2026-08-14 11:09:58');
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cart_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `variant_id` bigint unsigned DEFAULT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cart_product` (`cart_id`,`product_id`,`variant_id`),
  KEY `fk_cart_items_product` (`product_id`),
  KEY `fk_cart_items_variant` (`variant_id`),
  CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_cart_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
INSERT INTO `cart_items` VALUES (8,2,2,8,4,'2026-08-14 11:10:16','2026-08-14 11:10:16');
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_id` (`buyer_id`),
  CONSTRAINT `fk_carts_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
INSERT INTO `carts` VALUES (1,2,'2026-08-14 10:41:27','2026-08-14 10:41:27'),(2,3,'2026-08-14 11:07:07','2026-08-14 11:07:07'),(3,4,'2026-08-14 11:41:16','2026-08-14 11:41:16');
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Fashion','Apparel, shoes, bags and accessories',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(2,'Electronics','Gadgets, phones, and accessories',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(3,'Home & Living','Furniture, kitchen, and home decor',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(4,'Beauty & Health','Skincare, makeup, and wellness',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(5,'Sports & Outdoors','Fitness, camping, and sports gear',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(6,'Toys & Hobbies','Toys, collectibles, and games',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(7,'Groceries','Food, snacks, and daily essentials',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(8,'Books','Books, magazines, and stationery',NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `seller_id` bigint unsigned DEFAULT NULL,
  `subject` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_conversations_buyer` (`buyer_id`),
  CONSTRAINT `fk_conversations_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
INSERT INTO `conversations` VALUES (1,2,1,'Question about order','2026-08-14 10:43:14','2026-08-15 08:04:41'),(2,3,1,'clothes','2026-08-14 11:39:30','2026-08-15 08:04:50'),(3,7,5,'Inquiry about Headphones','2026-08-15 10:15:21','2026-08-15 10:15:21');
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courier_pickups`
--

DROP TABLE IF EXISTS `courier_pickups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courier_pickups` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `seller_id` bigint unsigned NOT NULL,
  `courier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pickup_at` datetime DEFAULT NULL,
  `tracking_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('scheduled','picked_up','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courier_pickups`
--

LOCK TABLES `courier_pickups` WRITE;
/*!40000 ALTER TABLE `courier_pickups` DISABLE KEYS */;
/*!40000 ALTER TABLE `courier_pickups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deliveries`
--

DROP TABLE IF EXISTS `deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deliveries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `rider_id` bigint unsigned DEFAULT NULL,
  `status` enum('waiting_for_rider','assigned','picked_up','out_for_delivery','delivered','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting_for_rider',
  `assigned_at` timestamp NULL DEFAULT NULL,
  `picked_up_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `delivery_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `fk_deliveries_rider` (`rider_id`),
  CONSTRAINT `fk_deliveries_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_deliveries_rider` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deliveries`
--

LOCK TABLES `deliveries` WRITE;
/*!40000 ALTER TABLE `deliveries` DISABLE KEYS */;
INSERT INTO `deliveries` VALUES (1,3,NULL,'waiting_for_rider',NULL,NULL,NULL,NULL,'2026-08-14 10:43:01','2026-08-14 10:43:01'),(2,4,NULL,'waiting_for_rider',NULL,NULL,NULL,NULL,'2026-08-14 10:56:31','2026-08-15 15:53:48'),(3,5,NULL,'waiting_for_rider',NULL,NULL,NULL,NULL,'2026-08-14 11:10:04','2026-08-14 11:10:04');
/*!40000 ALTER TABLE `deliveries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorites` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_favorite_buyer_product` (`buyer_id`,`product_id`),
  KEY `fk_favorites_product` (`product_id`),
  CONSTRAINT `fk_favorites_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_favorites_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint unsigned NOT NULL,
  `sender_id` bigint unsigned NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_messages_conversation` (`conversation_id`),
  KEY `fk_messages_sender` (`sender_id`),
  CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,1,2,'Hi, when will my order ship?',1,'2026-08-14 10:43:14'),(2,1,2,'pepe',1,'2026-08-14 11:03:23'),(3,2,3,'hello po',1,'2026-08-14 11:39:30'),(5,2,1,'ano po sadya nila',1,'2026-08-15 08:03:14'),(6,1,1,'tanginamo bastos',0,'2026-08-15 08:04:41'),(7,2,1,'edi wow',1,'2026-08-15 08:04:50'),(8,3,7,'Hi! Is this available?',1,'2026-08-15 10:15:21');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2026_08_15_000001_add_cost_price_to_products_table',1),(2,'2026_08_15_000002_add_seller_id_to_conversations_table',1),(3,'2026_08_15_000003_create_seller_notifications_table',1),(4,'2026_08_15_000004_create_courier_pickups_table',1),(5,'2026_08_15_000005_add_seller_id_to_vouchers_table',2),(6,'2026_08_19_000001_add_store_theme_to_sellers_table',3);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `seller_id` bigint unsigned NOT NULL,
  `product_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `variant_label` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int unsigned NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) GENERATED ALWAYS AS ((`quantity` * `price`)) STORED,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_order_items_order` (`order_id`),
  KEY `fk_order_items_product` (`product_id`),
  KEY `fk_order_items_seller` (`seller_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `chk_order_item_price` CHECK ((`price` >= 0)),
  CONSTRAINT `chk_order_item_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `seller_id`, `product_name`, `variant_label`, `quantity`, `price`, `created_at`) VALUES (1,3,1,1,'Classic White T-Shirt','Color: White',2,199.00,'2026-08-14 10:43:01'),(2,3,1,1,'Classic White T-Shirt','Color: Black',1,199.00,'2026-08-14 10:43:01'),(3,4,4,1,'Moisturizing Facial Serum','Size: 30ml',1,450.00,'2026-08-14 10:56:30'),(4,4,8,1,'Bestseller Hardbound Novel',NULL,2,499.00,'2026-08-14 10:56:30'),(5,5,1,1,'Classic White T-Shirt','Size: L',1,199.00,'2026-08-14 11:10:04');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_histories`
--

DROP TABLE IF EXISTS `order_status_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_histories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `from_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_order_status_histories_order` (`order_id`),
  CONSTRAINT `fk_order_status_histories_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_histories`
--

LOCK TABLES `order_status_histories` WRITE;
/*!40000 ALTER TABLE `order_status_histories` DISABLE KEYS */;
INSERT INTO `order_status_histories` VALUES (1,3,NULL,'pending','Order placed.','2026-08-14 10:43:01'),(2,4,NULL,'pending','Order placed.','2026-08-14 10:56:31'),(3,5,NULL,'pending','Order placed.','2026-08-14 11:10:04'),(11,5,'pending','confirmed','Order accepted by seller.','2026-08-15 08:02:38'),(12,5,'confirmed','processing','Order is being prepared.','2026-08-15 08:02:40');
/*!40000 ALTER TABLE `order_status_histories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_vouchers`
--

DROP TABLE IF EXISTS `order_vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_vouchers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `voucher_id` bigint unsigned NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_order_vouchers_order` (`order_id`),
  KEY `fk_order_vouchers_voucher` (`voucher_id`),
  CONSTRAINT `fk_order_vouchers_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_vouchers_voucher` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_vouchers`
--

LOCK TABLES `order_vouchers` WRITE;
/*!40000 ALTER TABLE `order_vouchers` DISABLE KEYS */;
INSERT INTO `order_vouchers` VALUES (1,3,1,100.00,'2026-08-14 10:43:01'),(2,4,2,150.00,'2026-08-14 10:56:31');
/*!40000 ALTER TABLE `order_vouchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `address_id` bigint unsigned NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('pending','confirmed','processing','ready_for_delivery','out_for_delivery','delivered','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_orders_buyer` (`buyer_id`),
  KEY `fk_orders_address` (`address_id`),
  CONSTRAINT `fk_orders_address` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `chk_order_total` CHECK ((`total_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (3,2,1,497.00,'pending',NULL,'2026-08-14 10:43:01','2026-08-15 15:53:48'),(4,2,1,1298.00,'pending',NULL,'2026-08-14 10:56:30','2026-08-15 15:53:48'),(5,3,2,199.00,'processing',NULL,'2026-08-14 11:10:04','2026-08-15 08:02:40');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `method` enum('cash_on_delivery','gcash','bank_transfer') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','paid','failed','refunded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `amount` decimal(10,2) NOT NULL,
  `reference_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_payment_amount` CHECK ((`amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,3,'cash_on_delivery','pending',497.00,NULL,NULL,'2026-08-14 10:43:01','2026-08-14 10:43:01'),(2,4,'cash_on_delivery','pending',1298.00,NULL,NULL,'2026-08-14 10:56:30','2026-08-15 15:53:48'),(3,5,'cash_on_delivery','pending',199.00,NULL,NULL,'2026-08-14 11:10:04','2026-08-14 11:10:04');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_tokenable` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',2,'invoiz-app','6ff747da486cd7a4edf589a00825159e2c0e270ff112ff48db9575745c6f9034','[\"*\"]','2026-08-14 10:41:37',NULL,'2026-08-14 10:41:37','2026-08-14 10:41:37'),(2,'App\\Models\\User',2,'invoiz-app','eb216f994e596d87500a658c2ebd9085e7939a46a626acefdc817acad37da230','[\"*\"]','2026-08-14 10:41:42',NULL,'2026-08-14 10:41:42','2026-08-14 10:41:42'),(3,'App\\Models\\User',2,'invoiz-app','0f5a3c60889bbfbc03992de753d1e060bdefd732107738f61e35fb64e0cc3aca','[\"*\"]','2026-08-14 10:41:45',NULL,'2026-08-14 10:41:45','2026-08-14 10:41:45'),(4,'App\\Models\\User',2,'invoiz-app','4018042bdb8488d88df0b2065495ba188e84b1faaf483b3d89002cfdd209cb1d','[\"*\"]','2026-08-14 10:41:49',NULL,'2026-08-14 10:41:49','2026-08-14 10:41:49'),(5,'App\\Models\\User',2,'invoiz-app','286fc93a094898177844d54d11e90d2bb465130528984c750ec89f73778e8817','[\"*\"]','2026-08-14 10:41:54',NULL,'2026-08-14 10:41:54','2026-08-14 10:41:54'),(6,'App\\Models\\User',2,'invoiz-app','e2060839888126a14ac04ba7bb085de5efa51d02829f24bf6a4b546b3f8d82aa','[\"*\"]','2026-08-14 10:42:00',NULL,'2026-08-14 10:42:00','2026-08-14 10:42:00'),(7,'App\\Models\\User',2,'invoiz-app','c9974dd1d9ed55e3fba6b9250f2f28e9defb0fb86b6d4496c4c2ccab94f43b74','[\"*\"]','2026-08-14 10:42:23',NULL,'2026-08-14 10:42:23','2026-08-14 10:42:23'),(8,'App\\Models\\User',2,'invoiz-app','678467058ac2c397fc7d4b4d26ab5d210d12b6b7e61440965cb5a1644e5224ee','[\"*\"]','2026-08-14 10:42:33',NULL,'2026-08-14 10:42:33','2026-08-14 10:42:33'),(9,'App\\Models\\User',2,'invoiz-app','9373c1448b03687bc43d8b3c0d6000ebde65f0bdb32b2996698253ff9064893b','[\"*\"]','2026-08-14 10:42:44',NULL,'2026-08-14 10:42:43','2026-08-14 10:42:44'),(10,'App\\Models\\User',2,'invoiz-app','17fadbbbd7058103bb1432de3c1da35f9c68b798a80ad63718943675d08f8ce0','[\"*\"]','2026-08-14 10:43:01',NULL,'2026-08-14 10:43:01','2026-08-14 10:43:01'),(11,'App\\Models\\User',2,'invoiz-app','8b64e25ef00c306270358db6e5f144973dea3331ae71fa75b151863f32af8e15','[\"*\"]','2026-08-14 10:43:05',NULL,'2026-08-14 10:43:05','2026-08-14 10:43:05'),(12,'App\\Models\\User',2,'invoiz-app','62756187873694bb0dadb508b0220bede763e4c14544169cd4f6ea2d5c2912e2','[\"*\"]','2026-08-14 10:43:08',NULL,'2026-08-14 10:43:08','2026-08-14 10:43:08'),(13,'App\\Models\\User',2,'invoiz-app','f8104d1a8c340392377dd5873410be1f8fac5a4312471f2af69f64db1d0b5286','[\"*\"]','2026-08-14 10:43:14',NULL,'2026-08-14 10:43:13','2026-08-14 10:43:14'),(14,'App\\Models\\User',2,'invoiz-app','5a4b61334b1311941c2fde1bf85660ef482205386704cb9f04c95a1fc47a000a','[\"*\"]','2026-08-14 10:56:31',NULL,'2026-08-14 10:56:30','2026-08-14 10:56:31'),(15,'App\\Models\\User',2,'invoiz-app','8b0f0ae9f4d1fcaa9a0847ce71ac06f3a29dd7840aa4a7e5f1da201086d80ece','[\"*\"]','2026-08-14 10:56:41',NULL,'2026-08-14 10:56:41','2026-08-14 10:56:41'),(17,'App\\Models\\User',3,'invoiz-app','10dda939c6197e7afb1273f35ffbad0903e16715338e4718ac9a093544e2926a','[\"*\"]','2026-08-14 11:11:27',NULL,'2026-08-14 11:07:58','2026-08-14 11:11:27'),(19,'App\\Models\\User',4,'invoiz-app','6015d359b29848ec2d7336813f3fda68fb42b5958f37077168cdaaa39636e785','[\"*\"]',NULL,NULL,'2026-08-14 11:42:10','2026-08-14 11:42:10'),(20,'App\\Models\\User',3,'invoiz-app','c053cff09b3d2be9193692be672f149f2a9f6d7dc4d899e94ef2c9ed98c6807e','[\"*\"]','2026-08-14 11:58:21',NULL,'2026-08-14 11:57:52','2026-08-14 11:58:21'),(22,'App\\Models\\User',2,'invoiz-app','60bf4ad6fea5b2bae7e09848b84c7be32b70a52529106a82399869df09fa0ad4','[\"*\"]','2026-08-14 12:26:26',NULL,'2026-08-14 12:26:25','2026-08-14 12:26:26'),(23,'App\\Models\\User',2,'invoiz-app','e71734cedfe5234b4b10aeeb1d5e83c4c4313843a00dc226b81a8a7783016441','[\"*\"]','2026-08-14 12:26:33',NULL,'2026-08-14 12:26:33','2026-08-14 12:26:33'),(24,'App\\Models\\User',2,'invoiz-app','fa6dd628fc8d1b0ed2cd1b49f765be70892948bb11a6cb5198fb0a81fa1d2b19','[\"*\"]','2026-08-14 12:30:34',NULL,'2026-08-14 12:30:33','2026-08-14 12:30:34'),(25,'App\\Models\\User',2,'invoiz-app','f940ab67b6991926f0a5e2d9290cfaa3d2da5df99d0394de47e01576f235269f','[\"*\"]','2026-08-14 12:30:47',NULL,'2026-08-14 12:30:47','2026-08-14 12:30:47'),(26,'App\\Models\\User',2,'invoiz-app','73f6320f3110698def397fdf3cca2b8fe50de0670d307c96785c398391d41199','[\"*\"]',NULL,NULL,'2026-08-14 12:30:48','2026-08-14 12:30:48'),(27,'App\\Models\\User',2,'invoiz-app','64b5b3a9f9cf330b7cdfef2bab013386b162a1abd20b9e6e874b9558ea1e5308','[\"*\"]','2026-08-14 12:30:54',NULL,'2026-08-14 12:30:54','2026-08-14 12:30:54'),(28,'App\\Models\\User',2,'invoiz-app','160849b2083b9c570208bf19d0137b228909d56c524f0549e9dc6e3fa2e5572e','[\"*\"]','2026-08-14 12:31:02',NULL,'2026-08-14 12:31:02','2026-08-14 12:31:02'),(29,'App\\Models\\User',2,'invoiz-app','bdb54def23edf2cb7afd2c29b5ea8a2ed83511dbd579c4568e95ebc494872551','[\"*\"]','2026-08-14 12:31:27',NULL,'2026-08-14 12:31:27','2026-08-14 12:31:27'),(30,'App\\Models\\User',2,'invoiz-app','78441368de03c4686766858a3a1a616fe81ff3613de2ab026dcaf033aaebe710','[\"*\"]','2026-08-14 12:41:23',NULL,'2026-08-14 12:41:23','2026-08-14 12:41:23'),(31,'App\\Models\\User',3,'invoiz-app','7bc09831ca1a6266c9ff9722cb7b13f42d641b69540c56381098809a6ea660ef','[\"*\"]',NULL,NULL,'2026-08-14 15:44:14','2026-08-14 15:44:14'),(34,'App\\Models\\User',3,'invoiz-app','9f3ee06d4399adbf8976543b42e306b3ad96a4893c362ff7c7f90405f8957100','[\"*\"]','2026-08-15 11:30:02',NULL,'2026-08-15 08:14:12','2026-08-15 11:30:02'),(35,'App\\Models\\User',3,'invoiz-app','b0899a5a48d81dbf12aaaf07cfa18e278c1398e15d3d07a6c6c07dfc1f547ddd','[\"*\"]','2026-08-15 08:37:32',NULL,'2026-08-15 08:37:06','2026-08-15 08:37:32'),(37,'App\\Models\\User',3,'invoiz-app','45d51990b73d468a5c39d7b47a94162218bdda6a86bd8974e8657e70092be503','[\"*\"]',NULL,NULL,'2026-08-15 08:54:53','2026-08-15 08:54:53'),(38,'App\\Models\\User',3,'invoiz-app','1c1192c05894ff94cf3c27d2f9b7ec7539dd19aecac4ba77e0e5eb58f6a39e2a','[\"*\"]',NULL,NULL,'2026-08-15 08:59:00','2026-08-15 08:59:00'),(39,'App\\Models\\User',2,'invoiz-app','4781fec9f3e58801f9475f36403254d8b9463c9ca7e3c22c9252ba22e84a9e88','[\"*\"]','2026-08-15 09:09:29',NULL,'2026-08-15 09:09:29','2026-08-15 09:09:29'),(40,'App\\Models\\User',2,'invoiz-app','5d2852f68d411148bf5e44ce9a8543b10f996ffa8a6d349af8ab43c734741827','[\"*\"]','2026-08-15 09:24:25',NULL,'2026-08-15 09:24:24','2026-08-15 09:24:25'),(41,'App\\Models\\User',2,'invoiz-app','f2148673efd62ffe47ec199bdf2e9141ca19240797149fb2ab1cb374a5d080d0','[\"*\"]','2026-08-15 09:35:31',NULL,'2026-08-15 09:35:31','2026-08-15 09:35:31'),(42,'App\\Models\\User',3,'invoiz-app','5186bac95edb1914025b9890b5184ff0cf7e0ca4cdf706c9a2a64046d6e1ebf0','[\"*\"]','2026-08-15 09:44:47',NULL,'2026-08-15 09:44:18','2026-08-15 09:44:47'),(43,'App\\Models\\User',7,'invoiz-app','f2791794cec7af1cf4bf1ff7eae83c0d660def30a8b372d66c7fb023f3adfca9','[\"*\"]','2026-08-15 10:15:06',NULL,'2026-08-15 10:15:05','2026-08-15 10:15:06'),(44,'App\\Models\\User',7,'invoiz-app','9cca45111a7fb439d5b7013c65e71dfd2e7ecb0ab211b8823eb345fb0d816207','[\"*\"]','2026-08-15 10:15:12',NULL,'2026-08-15 10:15:12','2026-08-15 10:15:12'),(45,'App\\Models\\User',7,'invoiz-app','18b68fbb72dbb0ddc970e6be8480d3494fd38b410905942dc010cf66f74fde71','[\"*\"]','2026-08-15 10:15:21',NULL,'2026-08-15 10:15:21','2026-08-15 10:15:21'),(46,'App\\Models\\User',7,'invoiz-app','6b802d5ea84c6015a4f9a9d7d5766a15dbac6b3c938f2d9d954f1b06da84c6b4','[\"*\"]','2026-08-15 10:15:30',NULL,'2026-08-15 10:15:30','2026-08-15 10:15:30'),(47,'App\\Models\\User',7,'invoiz-app','ab08b14fc1695773adf743347c515f98b965f6e0a2e355bb0aeedd1f6fb3991c','[\"*\"]','2026-08-15 10:21:26',NULL,'2026-08-15 10:21:25','2026-08-15 10:21:26'),(48,'App\\Models\\User',7,'invoiz-app','6e047816bba91343ba095ef9c81c4cfc5680c8106243f11c6edac8181334d121','[\"*\"]','2026-08-15 10:21:30',NULL,'2026-08-15 10:21:30','2026-08-15 10:21:30'),(49,'App\\Models\\User',3,'invoiz-app','f4064f8b789dcf2aebc0b3e65787729c431081a2b4d9972f89ee189a2c25b0fe','[\"*\"]','2026-08-15 10:28:17',NULL,'2026-08-15 10:28:10','2026-08-15 10:28:17'),(50,'App\\Models\\User',2,'invoiz-app','917be9fc6e27dcf4136e9ee859dd8da55c7f3dc368e753798f3f2cb15111e170','[\"*\"]','2026-08-15 10:30:41',NULL,'2026-08-15 10:30:40','2026-08-15 10:30:41'),(51,'App\\Models\\User',2,'invoiz-app','8f95435e9a2b4b4e152664c38a651a24117526ae65e3309ba7d6a2d307dc38e5','[\"*\"]','2026-08-15 10:31:16',NULL,'2026-08-15 10:31:16','2026-08-15 10:31:16'),(52,'App\\Models\\User',2,'invoiz-app','b169c5ee05664f4ab33ee8fb5bed24aa884bb535f112e4ca0cd4d5a2bdc98a6f','[\"*\"]','2026-08-15 10:39:34',NULL,'2026-08-15 10:39:33','2026-08-15 10:39:34'),(53,'App\\Models\\User',3,'invoiz-app','2244b2e98ce9c6d64897c2617e78a5c1dbc4e179346bf20079360294a0b97e90','[\"*\"]','2026-08-15 10:42:30',NULL,'2026-08-15 10:42:05','2026-08-15 10:42:30'),(54,'App\\Models\\User',3,'invoiz-app','afba5acddde22e8b5aab89958e6ebc34030cb66fb168d4ed4fa3a2e2f7f5f5ee','[\"*\"]','2026-08-15 10:52:37',NULL,'2026-08-15 10:52:21','2026-08-15 10:52:37'),(55,'App\\Models\\User',3,'invoiz-app','1cd493d82d9c0410b7a527bfc6b435f788ebd1c2201eb5982702b0fb02cde53f','[\"*\"]','2026-08-15 11:24:25',NULL,'2026-08-15 11:24:23','2026-08-15 11:24:25'),(56,'App\\Models\\User',3,'invoiz-app','639a6c3ea78607572cd8f625958052a65ccfbbb29bd578033ec096607675b735','[\"*\"]','2026-08-15 11:48:45',NULL,'2026-08-15 11:47:55','2026-08-15 11:48:45'),(57,'App\\Models\\User',2,'invoiz-app','74ab42d24d813d359e4165ea48a9172a670c7eece7f51073b9c53fbf2d15e00b','[\"*\"]',NULL,NULL,'2026-08-26 05:44:21','2026-08-26 05:44:21');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_product_images_product` (`product_id`),
  CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
INSERT INTO `product_images` VALUES (1,1,'products/p1_1.png',1,'2026-08-15 10:50:45'),(2,1,'products/p1_2.png',2,'2026-08-15 10:50:45'),(3,1,'products/p1_3.png',3,'2026-08-15 10:50:45'),(4,2,'products/p2_1.png',1,'2026-08-15 10:50:45'),(5,2,'products/p2_2.png',2,'2026-08-15 10:50:45'),(6,2,'products/p2_3.png',3,'2026-08-15 10:50:45'),(7,3,'products/p3_1.png',1,'2026-08-15 10:50:45'),(8,3,'products/p3_2.png',2,'2026-08-15 10:50:45'),(9,3,'products/p3_3.png',3,'2026-08-15 10:50:45'),(10,4,'products/p4_1.png',1,'2026-08-15 10:50:45'),(11,4,'products/p4_2.png',2,'2026-08-15 10:50:45'),(12,4,'products/p4_3.png',3,'2026-08-15 10:50:45'),(13,5,'products/p5_1.png',1,'2026-08-15 10:50:46'),(14,5,'products/p5_2.png',2,'2026-08-15 10:50:46'),(15,5,'products/p5_3.png',3,'2026-08-15 10:50:46'),(16,6,'products/p6_1.png',1,'2026-08-15 10:50:46'),(17,6,'products/p6_2.png',2,'2026-08-15 10:50:46'),(18,6,'products/p6_3.png',3,'2026-08-15 10:50:46'),(19,7,'products/p7_1.png',1,'2026-08-15 10:50:46'),(20,7,'products/p7_2.png',2,'2026-08-15 10:50:46'),(21,7,'products/p7_3.png',3,'2026-08-15 10:50:46'),(22,8,'products/p8_1.png',1,'2026-08-15 10:50:46'),(23,8,'products/p8_2.png',2,'2026-08-15 10:50:46'),(24,8,'products/p8_3.png',3,'2026-08-15 10:50:46'),(25,10,'products/p10_1.png',1,'2026-08-26 13:09:50'),(26,11,'products/p11_1.png',1,'2026-08-26 13:09:50'),(27,12,'products/p12_1.png',1,'2026-08-26 13:09:50'),(28,13,'products/p13_1.png',1,'2026-08-26 13:09:50'),(29,14,'products/p14_1.png',1,'2026-08-26 13:09:50'),(30,15,'products/p15_1.png',1,'2026-08-26 13:09:50'),(31,16,'products/p16_1.png',1,'2026-08-26 13:09:50'),(32,17,'products/p17_1.png',1,'2026-08-26 13:09:50'),(40,10,'products/p10_2.png',2,'2026-08-26 13:09:50'),(41,11,'products/p11_2.png',2,'2026-08-26 13:09:50'),(42,12,'products/p12_2.png',2,'2026-08-26 13:09:50'),(43,13,'products/p13_2.png',2,'2026-08-26 13:09:50'),(44,14,'products/p14_2.png',2,'2026-08-26 13:09:50'),(45,15,'products/p15_2.png',2,'2026-08-26 13:09:50'),(46,16,'products/p16_2.png',2,'2026-08-26 13:09:50'),(47,17,'products/p17_2.png',2,'2026-08-26 13:09:50'),(55,10,'products/p10_3.png',3,'2026-08-26 13:09:50'),(56,11,'products/p11_3.png',3,'2026-08-26 13:09:50'),(57,12,'products/p12_3.png',3,'2026-08-26 13:09:50'),(58,13,'products/p13_3.png',3,'2026-08-26 13:09:50'),(59,14,'products/p14_3.png',3,'2026-08-26 13:09:50'),(60,15,'products/p15_3.png',3,'2026-08-26 13:09:50'),(61,16,'products/p16_3.png',3,'2026-08-26 13:09:50'),(62,17,'products/p17_3.png',3,'2026-08-26 13:09:50');
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `variant_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `variant_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price_adjustment` decimal(10,2) NOT NULL DEFAULT '0.00',
  `stock` int unsigned NOT NULL DEFAULT '0',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_product_variants_product` (`product_id`),
  CONSTRAINT `fk_product_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (1,1,'Color','White',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(2,1,'Color','Black',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(3,1,'Color','Navy',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(4,1,'Size','S',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(5,1,'Size','M',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(6,1,'Size','L',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(7,1,'Size','XL',0.00,100,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(8,2,'Color','Black',0.00,50,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(9,2,'Color','White',0.00,50,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(10,3,'Color','Silver',0.00,80,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(11,3,'Color','Matte Black',0.00,80,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(12,3,'Color','Rose Gold',0.00,80,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(13,4,'Size','30ml',0.00,60,NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(14,4,'Size','50ml',0.00,60,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(15,5,'Color','Purple',0.00,40,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(16,5,'Color','Green',0.00,40,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(17,5,'Color','Blue',0.00,40,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(18,7,'Size','100g',0.00,200,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38'),(19,7,'Size','250g',0.00,200,NULL,'active','2026-08-14 10:40:38','2026-08-14 10:40:38');
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `seller_id` bigint unsigned NOT NULL,
  `category_id` bigint unsigned NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `material` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dimensions` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weight` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warranty` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `stock` int unsigned NOT NULL DEFAULT '0',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT NULL,
  `status` enum('active','inactive','out_of_stock') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_products_seller` (`seller_id`),
  KEY `fk_products_category` (`category_id`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_products_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `chk_product_price` CHECK ((`price` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,1,1,'Classic White T-Shirt','Premium cotton casual tee. Available in multiple colors and sizes.','BasicWear','BW-T100','TSH-WHT-199','100% Cotton','M 50x70 cm','180 g','No Warranty','Philippines',199.00,NULL,100,'products/p1_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(2,1,2,'Wireless Bluetooth Earbuds','True wireless earbuds with charging case and 24hr battery.','SoundPeak','SP-EB24','EAR-BT-899','ABS + Silicone','Case 6 x 4.5 x 2.5 cm','48 g','6 months','China',899.00,NULL,50,'products/p2_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(3,1,3,'Stainless Water Bottle 750ml','Insulated steel bottle keeps drinks cold/hot for hours.','Hydra','HY-750','BTL-STL-349','Stainless Steel','26 x 7 cm','340 g','No Warranty','China',349.00,NULL,80,'products/p3_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(4,1,4,'Moisturizing Facial Serum','Vitamin C serum for glowing, hydrated skin.','GlowLab','GL-C30','SRM-C30-450','Vitamin C + Hyaluronic Acid','Bottle 11 x 3.5 cm','70 g','No Warranty','Korea',450.00,NULL,60,'products/p4_1.png',5.0,'active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(5,1,5,'Yoga Mat Non-Slip','Eco-friendly TPE yoga mat with carry strap.','FlexFit','FF-TPE','YGA-TPE-599','TPE Foam','183 x 61 x 0.6 cm','900 g','No Warranty','China',599.00,NULL,40,'products/p5_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:46'),(6,1,6,'Building Blocks Set 500pcs','Colorful building bricks for endless creative play.','BuildPlay','BP-500','BLK-500-750','ABS Plastic','Box 30 x 22 x 12 cm','1.2 kg','No Warranty','China',750.00,NULL,30,'products/p6_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:46'),(7,1,7,'Instant Coffee 100g','Rich and aromatic 3-in-1 instant coffee.','BrewNest','BN-100','COF-100-120','Roasted coffee, creamer, sugar','Pouch 16 x 10 cm','100 g','No Warranty','Philippines',120.00,NULL,200,'products/p7_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:46'),(8,1,8,'Bestseller Hardbound Novel','A gripping hardbound fiction novel.','PaperTrail Books','PT-2301','BOK-HB-499','Paper, Hardcover','23 x 15 x 3 cm','450 g','No Warranty','Philippines',499.00,NULL,25,'products/p8_1.png',NULL,'active','2026-08-14 10:40:38','2026-08-15 10:50:46'),(10,5,2,'Noise-Cancelling Headphones Pro','Noise-Cancelling Headphones Pro â€” available now at TechNest Gadgets.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2499.00,899.00,40,'products/p10_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(11,5,2,'Smartphone Stand Aluminum','Smartphone Stand Aluminum â€” available now at TechNest Gadgets.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,499.00,220.00,120,'products/p11_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(12,5,2,'Mechanical Keyboard RGB','Mechanical Keyboard RGB â€” available now at TechNest Gadgets.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1899.00,800.00,25,'products/p12_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(13,5,2,'Fast Charging Power Bank 20K','Fast Charging Power Bank 20K â€” available now at TechNest Gadgets.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,999.00,450.00,60,'products/p13_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(14,6,7,'Organic Brown Rice 5kg','Organic Brown Rice 5kg â€” available now at FreshMart PH.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,599.00,420.00,80,'products/p14_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(15,6,7,'Pure Honey 250ml','Pure Honey 250ml â€” available now at FreshMart PH.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,349.00,200.00,55,'products/p15_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(16,6,7,'Filtered Water 1L (12-pack)','Filtered Water 1L (12-pack) â€” available now at FreshMart PH.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180.00,90.00,200,'products/p16_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(17,6,7,'Crunchy Peanut Butter 500g','Crunchy Peanut Butter 500g â€” available now at FreshMart PH.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,249.00,140.00,75,'products/p17_1.png',4.0,'active','2026-08-15 10:13:35','2026-08-26 13:09:50'),(18,1,4,'Cute ren','cute lang sya',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1110.98,1.01,1,'products/yiNoWJrwSjwBECoyIXqFuHCsfLON3InTMkUhXTSZ.jpg',NULL,'active','2026-08-15 10:50:09','2026-08-15 10:50:09');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `order_id` bigint unsigned NOT NULL,
  `rating` tinyint unsigned NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('visible','hidden') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'visible',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_buyer_product_order` (`buyer_id`,`product_id`,`order_id`),
  KEY `fk_reviews_product` (`product_id`),
  KEY `fk_reviews_order` (`order_id`),
  CONSTRAINT `fk_reviews_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_review_rating` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,2,4,4,5,'Great product!','visible','2026-08-14 10:56:31','2026-08-14 10:56:31');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_notifications`
--

DROP TABLE IF EXISTS `seller_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `seller_id` bigint unsigned NOT NULL,
  `order_id` bigint unsigned DEFAULT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'order',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_notifications_seller_id_is_read_index` (`seller_id`,`is_read`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_notifications`
--

LOCK TABLES `seller_notifications` WRITE;
/*!40000 ALTER TABLE `seller_notifications` DISABLE KEYS */;
INSERT INTO `seller_notifications` VALUES (13,1,3,NULL,'new_order','New order received','Order #3 from Juan Carlo  Dela Cruz needs your attention.',0,'2026-08-15 07:53:55','2026-08-15 07:53:55'),(14,1,4,NULL,'new_order','New order received','Order #4 from Juan Carlo  Dela Cruz needs your attention.',0,'2026-08-15 07:53:55','2026-08-15 07:53:55'),(15,1,5,NULL,'new_order','New order received','Order #5 from Renee Rose D Tuason needs your attention.',0,'2026-08-15 07:53:55','2026-08-15 07:53:55'),(16,1,4,4,'review','New customer review','Juan Carlo  Dela Cruz rated Moisturizing Facial Serum 5/5.',0,'2026-08-15 07:53:55','2026-08-15 07:53:55'),(17,1,5,NULL,'status','Order accepted','Order #5 is now confirmed.',0,'2026-08-15 08:02:38','2026-08-15 08:02:38'),(18,1,5,NULL,'status','Order is being prepared','Order #5 is now processing.',1,'2026-08-15 08:02:40','2026-08-15 08:05:01');
/*!40000 ALTER TABLE `seller_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sellers`
--

DROP TABLE IF EXISTS `sellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sellers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `business_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `line_of_business` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `primary_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#16697A',
  `accent_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#F0A202',
  `logo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `business_permit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `sellers_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sellers`
--

LOCK TABLES `sellers` WRITE;
/*!40000 ALTER TABLE `sellers` DISABLE KEYS */;
INSERT INTO `sellers` VALUES (4,1,'Invoiz Demo Store','General Merchandise','#16697A','#F0A202',NULL,NULL,NULL,'approved','active','2026-08-15 07:47:22','2026-08-15 07:47:22'),(5,3,'akjshd','Home & Living','#16697A','#F0A202',NULL,'seller-ids/RsPZtj93KeF8Htkrusdc5dmGbpk4Sho3ZmnDogDi.png','seller-permits/okYnQhd7o8n8pOQZYrWZLMrLy7wnnwDskIMbUjft.png','approved','active','2026-08-15 08:37:31','2026-08-15 16:39:44'),(6,5,'TechNest Gadgets','Electronics & Gadgets','#16697A','#F0A202',NULL,NULL,NULL,'approved','active','2026-08-15 10:13:35','2026-08-15 10:13:35'),(7,6,'FreshMart PH','Groceries & Home Essentials','#16697A','#F0A202',NULL,NULL,NULL,'approved','active','2026-08-15 10:13:35','2026-08-15 10:13:35');
/*!40000 ALTER TABLE `sellers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_sessions_user` (`user_id`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('7wH2n6CpU0TAzhtoZkZl3WpYDnfHGgcnzFbtenGs',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','eyJfdG9rZW4iOiJwbkJtV2hiTlZXY3p2Z2JWWGcyYjFzWFpsbjFVRlBlVkh0M3lJaHVpIiwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJfcHJldmlvdXMiOnsidXJsIjoiaHR0cDpcL1wvMTI3LjAuMC4xOjgxMDBcL3Byb2R1Y3RzXC8xXC9lZGl0Iiwicm91dGUiOiJzZWxsZXIucHJvZHVjdHMuZWRpdCJ9LCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6MX0=',1786821888),('HyQrzA93VW0YOcNKCyXIOPZmCmXBYqL7hpIIkh5r',5,'127.0.0.1','curl/8.21.0','eyJfdG9rZW4iOiJJZUx3S25VUW5xeTE3VVBhNzB5bjNGQnZ1S0xYWjU2TU13WldYNDBvIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MTAwXC9jaGF0Iiwicm91dGUiOiJzZWxsZXIuY2hhdC5pbmRleCJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX0sImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjo1fQ==',1786817771),('IjYpuoUTSF2NeCblswClFyUyRqLnuK1aFx4uV4TG',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.133.0 Chrome/148.0.7778.280 Electron/42.8.0 Safari/537.36','eyJfdG9rZW4iOiJVaTdWSmFJOHlTT2liM2U0OU1zR0I5V20yaE9WT2RvcVpOdTBUaDNZIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9sb2dpbiIsInJvdXRlIjoic2VsbGVyLmxvZ2luIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=',1786922608),('lbkhj9qvZYCvUSIp5fpUGGcarOHWL2jmayZlDQVN',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','eyJfdG9rZW4iOiI5aDFuT1hyYXdGRHJ4R3FoVnU0T3dIeDRGcjJhbUJXWTBLVFRmVVpSIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hY2NvdW50Iiwicm91dGUiOiJzZWxsZXIuYWNjb3VudCJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX0sImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjoxfQ==',1786922832),('UvZCsPpjwTyQVpahebIYGbKXf35ykTgHf2jKlyns',5,'127.0.0.1','curl/8.21.0','eyJfdG9rZW4iOiJhSTdaeEQwRTFNdGRiM0lxM20yVEVwOFdSS3h1YnhTUkp2QUtPTDhWIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MTAwXC9jaGF0XC8zIiwicm91dGUiOiJzZWxsZXIuY2hhdC5zaG93In0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjV9',1786817789);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_follows`
--

DROP TABLE IF EXISTS `store_follows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_follows` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_id` bigint unsigned NOT NULL,
  `seller_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_store_follow_buyer_seller` (`buyer_id`,`seller_id`),
  KEY `fk_store_follows_seller` (`seller_id`),
  CONSTRAINT `fk_store_follows_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_store_follows_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_follows`
--

LOCK TABLES `store_follows` WRITE;
/*!40000 ALTER TABLE `store_follows` DISABLE KEYS */;
INSERT INTO `store_follows` VALUES (5,3,5,'2026-08-15 10:42:26');
/*!40000 ALTER TABLE `store_follows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_initial` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sex` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `birthday` date NOT NULL,
  `age` int unsigned NOT NULL,
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `municipality` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barangay` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address_line` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `role` enum('admin','seller','buyer','rider') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'buyer',
  `status` enum('active','inactive','suspended') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Invoiz','Demo Seller',NULL,'other','seller@invoiz.test','$2y$12$iuXqWSaSqipDTWSho6WOIOYfgtJfUWLdT5V0jnEhUzbIgX2HyABCG','09170000000','1990-01-01',36,NULL,NULL,NULL,NULL,NULL,'approved','seller','active','2026-08-14 10:40:38','2026-08-15 10:50:45'),(2,'Dela Cruz','Juan Carlo',NULL,'male','juan@test.com','$2y$12$KChTXEEhrTtjUg1X7H86/.qx9lNMu4yoyEjMGNFn7CwaTJt78U3FS','09171112233','2000-01-15',26,NULL,NULL,NULL,NULL,NULL,'approved','buyer','active','2026-08-14 10:41:27','2026-08-14 10:56:41'),(3,'Tuason','Renee Rose','D','female','reneerosetuason@gmail.com','$2y$12$546oWbGUO8jdXzbxfhISXuh7mIp62PF2DhfQRX9bhXG4H.HQteg.G','09307570755','2006-09-02',19,'Laguna','Lumban','Maytalang I','Cailles Street','ids/tL76Xt5zMXvN3OR9Ja7ex6KAQs46ymjaeseNpRqb.png','approved','buyer','active','2026-08-14 11:07:07','2026-08-14 19:07:54'),(4,'asdasd','asdasd','asdasd','female','asdasd@gmail.com','$2y$12$AmbwUkrM5L9CRizuouoY6O5IxBuC7dTrG6g4wbAWvzl1n.D6.KYB.','aasasd','2000-01-25',26,'Laguna','Lumban','Maytalang I','asdasd',NULL,'approved','buyer','active','2026-08-14 11:41:16','2026-08-14 19:41:49'),(5,'Store','TechNest',NULL,'other','tech@invoiz.test','$2y$12$xA1xWyVzCTNGfQNhpZtvcOQPr56A177zVyrpfbHlKT85iUBb6zgdG','09170000000','1990-01-01',35,NULL,NULL,NULL,NULL,NULL,'approved','seller','active','2026-08-15 10:13:35','2026-08-15 10:13:35'),(6,'Store','FreshMart',NULL,'other','fresh@invoiz.test','$2y$12$rEUAb97HoYVAlcZl3DDKyukuMUM4dZZAJ7N7ydDLvPDEJJirtTrs2','09170000000','1990-01-01',35,NULL,NULL,NULL,NULL,NULL,'approved','seller','active','2026-08-15 10:13:35','2026-08-15 10:13:35'),(7,'Test','Buyer',NULL,'other','buyer@test.com','$2y$12$bN5elLs3fjxJHgrQpWcdauQ0kVmYACo5v2hMGnnMqZuUJam3fL00y','09170000001','1995-05-05',30,NULL,NULL,NULL,NULL,NULL,'approved','buyer','active','2026-08-15 18:14:56','2026-08-15 18:14:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vouchers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `seller_id` bigint unsigned DEFAULT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `discount_type` enum('fixed','percent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fixed',
  `discount_value` decimal(10,2) NOT NULL,
  `min_spend` decimal(10,2) NOT NULL DEFAULT '0.00',
  `max_discount` decimal(10,2) DEFAULT NULL,
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `usage_limit` int unsigned DEFAULT NULL,
  `used_count` int unsigned NOT NULL DEFAULT '0',
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  CONSTRAINT `chk_voucher_value` CHECK ((`discount_value` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vouchers`
--

LOCK TABLES `vouchers` WRITE;
/*!40000 ALTER TABLE `vouchers` DISABLE KEYS */;
INSERT INTO `vouchers` VALUES (1,NULL,'WELCOME10','Welcome Voucher','P100 off any order','fixed',100.00,500.00,NULL,NULL,NULL,NULL,1,'active','2026-08-14 10:40:38','2026-08-14 10:43:01'),(2,NULL,'SAVE15','Save 15%','15% off up to P150','percent',15.00,1000.00,150.00,NULL,NULL,NULL,1,'active','2026-08-14 10:40:38','2026-08-14 10:56:31'),(3,NULL,'FREESHIP','Free Delivery','P50 off any order','fixed',50.00,300.00,NULL,NULL,NULL,NULL,0,'active','2026-08-14 10:40:38','2026-08-14 10:40:38');
/*!40000 ALTER TABLE `vouchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'invoizdb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-26 22:03:53

package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

@Mapper
public interface OrderMapper {

    String GOODS_COLUMNS = "id, category_id, name, main_image, images, detail, price, original_price, stock, unit, " +
            "sales_volume, is_recommend, is_flash, flash_price, flash_start_time, flash_end_time, flash_stock, " +
            "home_sort, show_in_home, status, origin, keywords, create_time";
    String SKU_COLUMNS = "id, goods_id, sku_name, sku_weight_g, sku_price, sku_stock, status, sort";
    String ORDER_COLUMNS = "id, order_no, user_id, total_amount, discount_amount, actual_amount, receiver_name, receiver_phone, " +
            "receiver_address, remark, coupon_id, order_source, status, pay_channel, pay_trade_no, pay_status, pay_time, deliver_time, " +
            "finish_time, cancel_time, create_time";
    String ORDER_ITEM_COLUMNS = "id, order_id, goods_id, sku_id, goods_name, goods_image, sku_name, sku_weight_g, price, quantity, total_price, source_type, source_plan_id, source_scene";

    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE id = #{goodsId} FOR UPDATE")
    Goods selectGoodsForUpdate(@Param("goodsId") Long goodsId);

    @Select("SELECT " + SKU_COLUMNS + " FROM goods_sku WHERE id = #{skuId} FOR UPDATE")
    GoodsSku selectSkuForUpdate(@Param("skuId") Long skuId);

    @Update("UPDATE goods_sku SET sku_stock = sku_stock - #{quantity} " +
            "WHERE id = #{skuId} AND sku_stock >= #{quantity}")
    int deductSkuStock(@Param("skuId") Long skuId, @Param("quantity") Integer quantity);

    @Update("UPDATE goods SET flash_stock = flash_stock - #{quantity} " +
            "WHERE id = #{goodsId} AND flash_stock >= #{quantity}")
    int deductFlashStock(@Param("goodsId") Long goodsId, @Param("quantity") Integer quantity);

    @Insert("INSERT INTO `order`(order_no, user_id, total_amount, discount_amount, actual_amount, " +
            "receiver_name, receiver_phone, receiver_address, remark, coupon_id, order_source, status, pay_status) " +
            "VALUES(#{orderNo}, #{userId}, #{totalAmount}, #{discountAmount}, #{actualAmount}, " +
            "#{receiverName}, #{receiverPhone}, #{receiverAddress}, #{remark}, #{couponId}, #{orderSource}, #{status}, #{payStatus})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertOrder(OrderInfo orderInfo);

    @Insert("INSERT INTO order_item(order_id, goods_id, sku_id, goods_name, goods_image, sku_name, sku_weight_g, price, quantity, total_price, source_type, source_plan_id, source_scene) " +
            "VALUES(#{orderId}, #{goodsId}, #{skuId}, #{goodsName}, #{goodsImage}, #{skuName}, #{skuWeightG}, #{price}, #{quantity}, #{totalPrice}, #{sourceType}, #{sourcePlanId}, #{sourceScene})")
    int insertOrderItem(OrderItemInfo orderItemInfo);

    @Select("SELECT " + ORDER_COLUMNS + " FROM `order` WHERE user_id = #{userId} ORDER BY create_time DESC LIMIT #{limit}")
    List<OrderInfo> selectOrderListByUserId(@Param("userId") Long userId, @Param("limit") Integer limit);

    @Select("SELECT " + ORDER_COLUMNS + " FROM `order` WHERE user_id = #{userId} AND status = #{status} ORDER BY create_time DESC LIMIT #{limit}")
    List<OrderInfo> selectOrderListByUserIdAndStatus(@Param("userId") Long userId,
                                                      @Param("status") Integer status,
                                                      @Param("limit") Integer limit);

    @Select("SELECT " + ORDER_COLUMNS + " FROM `order` WHERE id = #{orderId} AND user_id = #{userId} LIMIT 1")
    OrderInfo selectOrderByIdAndUserId(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE `order` SET status = #{toStatus} WHERE id = #{orderId} AND user_id = #{userId} AND status = #{fromStatus}")
    int updateOrderStatus(@Param("orderId") Long orderId,
                          @Param("userId") Long userId,
                          @Param("fromStatus") Integer fromStatus,
                          @Param("toStatus") Integer toStatus);

    @Update("UPDATE `order` SET status = 3, finish_time = NOW() WHERE id = #{orderId} AND user_id = #{userId} AND status = 2")
    int finishOrder(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE `order` SET pay_channel = #{payChannel}, pay_trade_no = #{payTradeNo}, pay_status = 1 " +
            "WHERE id = #{orderId} AND user_id = #{userId} AND status = 0")
    int createMockPay(@Param("orderId") Long orderId,
                      @Param("userId") Long userId,
                      @Param("payChannel") String payChannel,
                      @Param("payTradeNo") String payTradeNo);

    @Update("UPDATE `order` SET status = 1, pay_status = 2, pay_time = NOW() " +
            "WHERE id = #{orderId} AND user_id = #{userId} AND status = 0 AND pay_status = 1 AND pay_trade_no = #{payTradeNo}")
    int confirmMockPay(@Param("orderId") Long orderId,
                       @Param("userId") Long userId,
                       @Param("payTradeNo") String payTradeNo);

    @Update("UPDATE `order` SET status = 2, deliver_time = NOW() WHERE id = #{orderId} AND user_id = #{userId} AND status = 1")
    int deliverOrder(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE `order` SET status = 7 WHERE id = #{orderId} AND user_id = #{userId} AND status IN (1, 2, 3)")
    int applyRefund(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE `order` SET status = 5 WHERE id = #{orderId} AND user_id = #{userId} AND status = 6")
    int finishRefund(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE goods_sku s " +
            "JOIN order_item oi ON oi.sku_id = s.id " +
            "SET s.sku_stock = s.sku_stock + oi.quantity " +
            "WHERE oi.order_id = #{orderId}")
    int restoreSkuStockByOrderId(@Param("orderId") Long orderId);

    @Update("UPDATE goods g " +
            "JOIN (" +
            "  SELECT goods_id, SUM(quantity) AS total_qty FROM order_item " +
            "  WHERE order_id = #{orderId} AND source_type = 'FLASH' GROUP BY goods_id" +
            ") t ON t.goods_id = g.id " +
            "SET g.flash_stock = g.flash_stock + t.total_qty")
    int restoreFlashStockByOrderId(@Param("orderId") Long orderId);

    @Select("SELECT " +
            "oi.id, oi.order_id, oi.goods_id, oi.sku_id, oi.goods_name, oi.goods_image, oi.sku_name, oi.sku_weight_g, oi.price, oi.quantity, oi.total_price, oi.source_type, oi.source_plan_id, oi.source_scene, " +
            "IFNULL(c.comment_count, 0) AS comment_count, " +
            "CASE WHEN IFNULL(c.comment_count, 0) > 0 THEN 1 ELSE 0 END AS has_commented, " +
            "c.comment_id AS comment_id " +
            "FROM order_item oi " +
            "LEFT JOIN (" +
            "  SELECT order_id, goods_id, COUNT(1) AS comment_count, MAX(id) AS comment_id " +
            "  FROM comment WHERE user_id = #{userId} GROUP BY order_id, goods_id" +
            ") c ON c.order_id = oi.order_id AND c.goods_id = oi.goods_id " +
            "WHERE oi.order_id = #{orderId} ORDER BY oi.id ASC")
    List<OrderItemInfo> selectOrderItemsByOrderId(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Select("<script>" +
            "SELECT " + ORDER_COLUMNS + " FROM `order` WHERE 1 = 1 " +
            "<if test='status != null'> AND status = #{status} </if>" +
            "<if test='userId != null'> AND user_id = #{userId} </if>" +
            "ORDER BY create_time DESC" +
            "</script>")
    List<OrderInfo> selectAdminOrderList(@Param("status") Integer status, @Param("userId") Long userId);

    @Select("SELECT " + ORDER_COLUMNS + " FROM `order` WHERE id = #{orderId} LIMIT 1")
    OrderInfo selectOrderById(@Param("orderId") Long orderId);

    @Update("UPDATE `order` SET status = #{status} WHERE id = #{orderId}")
    int updateOrderStatusDirect(@Param("orderId") Long orderId, @Param("status") Integer status);

    @Update("UPDATE `order` SET status = #{toStatus} WHERE id = #{orderId} AND status = #{fromStatus}")
    int updateOrderStatusIfCurrent(@Param("orderId") Long orderId,
                                   @Param("fromStatus") Integer fromStatus,
                                   @Param("toStatus") Integer toStatus);

    @Select("SELECT COUNT(1) FROM `order`")
    Integer countAllOrders();

    @Select("SELECT COUNT(1) FROM `order` WHERE status = 1")
    Integer countPendingDeliveryOrders();

    @Select("SELECT COALESCE(SUM(actual_amount), 0) FROM `order` WHERE pay_status = 2")
    java.math.BigDecimal sumPaidActualAmount();

    @Select("SELECT COUNT(1) FROM `order` WHERE order_source = #{orderSource}")
    Integer countOrdersBySource(@Param("orderSource") String orderSource);

    @Select("SELECT COUNT(DISTINCT oi.order_id) " +
            "FROM order_item oi " +
            "INNER JOIN `order` o ON o.id = oi.order_id " +
            "WHERE oi.source_type = #{sourceType} AND o.pay_status = 2")
    Integer countPaidOrdersContainingItemSource(@Param("sourceType") String sourceType);

    @Select("SELECT COUNT(1) FROM `order` WHERE order_source = #{orderSource} AND pay_status = 2")
    Integer countPaidOrdersBySource(@Param("orderSource") String orderSource);

    @Select("SELECT oi.sku_id AS skuId, COALESCE(SUM(oi.quantity), 0) AS salesVolume " +
            "FROM order_item oi " +
            "INNER JOIN `order` o ON o.id = oi.order_id " +
            "WHERE oi.sku_id IS NOT NULL AND o.pay_status = 2 " +
            "GROUP BY oi.sku_id")
    List<Map<String, Object>> selectPaidSkuSalesSummary();

    @Select("SELECT " + ORDER_COLUMNS + " FROM `order` ORDER BY id ASC")
    List<OrderInfo> selectAllOrders();

    @Select("SELECT id, source_scene AS source_scene FROM order_item WHERE source_scene IS NOT NULL AND source_scene <> ''")
    List<OrderItemInfo> selectAllSourceSceneRows();

    @Update("UPDATE order_item SET source_scene = #{sourceScene} WHERE id = #{id}")
    int updateOrderItemSourceSceneById(@Param("id") Long id, @Param("sourceScene") String sourceScene);

    @Select("SELECT " + ORDER_ITEM_COLUMNS + " FROM order_item WHERE order_id = #{orderId} ORDER BY id ASC")
    List<OrderItemInfo> selectOrderItemsByOrderIdRaw(@Param("orderId") Long orderId);

    @Update("UPDATE order_item SET source_type = #{sourceType}, source_scene = #{sourceScene} WHERE id = #{id}")
    int updateOrderItemSourceFieldsById(@Param("id") Long id, @Param("sourceType") String sourceType, @Param("sourceScene") String sourceScene);

    @Update("UPDATE `order` SET order_source = #{orderSource} WHERE id = #{orderId}")
    int updateOrderSourceById(@Param("orderId") Long orderId, @Param("orderSource") String orderSource);

    @org.apache.ibatis.annotations.Delete("DELETE oi FROM order_item oi INNER JOIN `order` o ON oi.order_id = o.id WHERE o.user_id = #{userId}")
    int deleteOrderItemsByUserId(@Param("userId") Long userId);

    @org.apache.ibatis.annotations.Delete("DELETE FROM `order` WHERE user_id = #{userId}")
    int deleteOrdersByUserId(@Param("userId") Long userId);
}

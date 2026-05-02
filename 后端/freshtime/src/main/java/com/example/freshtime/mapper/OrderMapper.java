package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface OrderMapper {

    @Select("SELECT * FROM goods WHERE id = #{goodsId} FOR UPDATE")
    Goods selectGoodsForUpdate(@Param("goodsId") Long goodsId);

    @Update("UPDATE goods SET stock = stock - #{quantity}, sales_volume = sales_volume + #{quantity} " +
            "WHERE id = #{goodsId} AND stock >= #{quantity}")
    int deductGoodsStock(@Param("goodsId") Long goodsId, @Param("quantity") Integer quantity);

    @Insert("INSERT INTO `order`(order_no, user_id, merchant_id, total_amount, discount_amount, actual_amount, " +
            "receiver_name, receiver_phone, receiver_address, remark, status, pay_status) " +
            "VALUES(#{orderNo}, #{userId}, #{merchantId}, #{totalAmount}, #{discountAmount}, #{actualAmount}, " +
            "#{receiverName}, #{receiverPhone}, #{receiverAddress}, #{remark}, #{status}, #{payStatus})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertOrder(OrderInfo orderInfo);

    @Insert("INSERT INTO order_item(order_id, goods_id, goods_name, goods_image, price, quantity, total_price) " +
            "VALUES(#{orderId}, #{goodsId}, #{goodsName}, #{goodsImage}, #{price}, #{quantity}, #{totalPrice})")
    int insertOrderItem(OrderItemInfo orderItemInfo);

    @Select("SELECT * FROM `order` WHERE user_id = #{userId} ORDER BY create_time DESC LIMIT #{limit}")
    List<OrderInfo> selectOrderListByUserId(@Param("userId") Long userId, @Param("limit") Integer limit);

    @Select("SELECT * FROM `order` WHERE user_id = #{userId} AND status = #{status} ORDER BY create_time DESC LIMIT #{limit}")
    List<OrderInfo> selectOrderListByUserIdAndStatus(@Param("userId") Long userId,
                                                      @Param("status") Integer status,
                                                      @Param("limit") Integer limit);

    @Select("SELECT * FROM `order` WHERE id = #{orderId} AND user_id = #{userId} LIMIT 1")
    OrderInfo selectOrderByIdAndUserId(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE `order` SET status = #{toStatus} WHERE id = #{orderId} AND user_id = #{userId} AND status = #{fromStatus}")
    int updateOrderStatus(@Param("orderId") Long orderId,
                          @Param("userId") Long userId,
                          @Param("fromStatus") Integer fromStatus,
                          @Param("toStatus") Integer toStatus);

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

    @Update("UPDATE `order` SET status = 6 WHERE id = #{orderId} AND user_id = #{userId} AND status IN (1, 2)")
    int applyRefund(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE `order` SET status = 5 WHERE id = #{orderId} AND user_id = #{userId} AND status = 6")
    int finishRefund(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE goods g " +
            "JOIN order_item oi ON oi.goods_id = g.id " +
            "SET g.stock = g.stock + oi.quantity, " +
            "g.sales_volume = CASE WHEN g.sales_volume >= oi.quantity THEN g.sales_volume - oi.quantity ELSE 0 END " +
            "WHERE oi.order_id = #{orderId}")
    int restoreGoodsStockByOrderId(@Param("orderId") Long orderId);

    @Select("SELECT * FROM order_item WHERE order_id = #{orderId} ORDER BY id ASC")
    List<OrderItemInfo> selectOrderItemsByOrderId(@Param("orderId") Long orderId);

    @org.apache.ibatis.annotations.Delete("DELETE oi FROM order_item oi INNER JOIN `order` o ON oi.order_id = o.id WHERE o.user_id = #{userId}")
    int deleteOrderItemsByUserId(@Param("userId") Long userId);

    @org.apache.ibatis.annotations.Delete("DELETE FROM `order` WHERE user_id = #{userId}")
    int deleteOrdersByUserId(@Param("userId") Long userId);
}

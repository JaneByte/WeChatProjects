package com.example.freshtime.mapper;

import com.example.freshtime.entity.CouponInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;

import java.util.List;

@Mapper
public interface CouponMapper {

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status, create_time " +
            "FROM user_coupon " +
            "WHERE user_id = #{userId} AND status = 1 " +
            "ORDER BY expire_date ASC, id DESC")
    List<CouponInfo> selectActiveByUserId(@Param("userId") Long userId);

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status, create_time " +
            "FROM user_coupon WHERE id = #{id} AND user_id = #{userId} LIMIT 1")
    CouponInfo selectByIdAndUserId(@Param("id") Long id, @Param("userId") Long userId);

    @org.apache.ibatis.annotations.Update("UPDATE user_coupon SET status = 2 WHERE id = #{id} AND user_id = #{userId} AND status = 1")
    int markUsed(@Param("id") Long id, @Param("userId") Long userId);

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status, create_time " +
            "FROM user_coupon WHERE user_id = #{userId} AND title = #{title} AND expire_date = #{expireDate} AND status = 1 LIMIT 1")
    CouponInfo selectActiveByUserIdAndTitle(@Param("userId") Long userId,
                                            @Param("title") String title,
                                            @Param("expireDate") java.time.LocalDate expireDate);

    @Insert("INSERT INTO user_coupon(user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status) " +
            "VALUES(#{userId}, #{title}, #{conditionText}, #{thresholdAmount}, #{discountAmount}, #{expireDate}, #{status})")
    int insertCoupon(CouponInfo couponInfo);
}

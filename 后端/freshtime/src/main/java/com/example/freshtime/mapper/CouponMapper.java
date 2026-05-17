package com.example.freshtime.mapper;

import com.example.freshtime.entity.CouponInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CouponMapper {
    @Select("SELECT id, name AS title, description AS condition_text, threshold_amount, discount_amount, expire_date, status " +
            "FROM coupon WHERE status = 1 ORDER BY threshold_amount ASC, discount_amount DESC, id DESC")
    List<CouponInfo> selectCouponPool();

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status " +
            "FROM user_coupon " +
            "WHERE user_id = #{userId} AND status = 1 " +
            "ORDER BY expire_date ASC, id DESC")
    List<CouponInfo> selectActiveByUserId(@Param("userId") Long userId);

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status " +
            "FROM user_coupon WHERE id = #{id} AND user_id = #{userId} LIMIT 1")
    CouponInfo selectByIdAndUserId(@Param("id") Long id, @Param("userId") Long userId);

    @org.apache.ibatis.annotations.Update("UPDATE user_coupon SET status = 2 WHERE id = #{id} AND user_id = #{userId} AND status = 1")
    int markUsed(@Param("id") Long id, @Param("userId") Long userId);

    @org.apache.ibatis.annotations.Update("UPDATE user_coupon SET status = 1 WHERE id = #{id} AND user_id = #{userId} AND status = 2")
    int markUnused(@Param("id") Long id, @Param("userId") Long userId);

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status " +
            "FROM user_coupon WHERE user_id = #{userId} AND title = #{title} AND expire_date = #{expireDate} AND status = 1 LIMIT 1")
    CouponInfo selectActiveByUserIdAndTitle(@Param("userId") Long userId,
                                            @Param("title") String title,
                                            @Param("expireDate") java.time.LocalDate expireDate);

    @Insert("INSERT INTO user_coupon(user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status) " +
            "VALUES(#{userId}, #{title}, #{conditionText}, #{thresholdAmount}, #{discountAmount}, #{expireDate}, #{status})")
    int insertCoupon(CouponInfo couponInfo);

    @Select("SELECT id, user_id, title, condition_text, threshold_amount, discount_amount, expire_date, status " +
            "FROM user_coupon WHERE user_id = #{userId} AND title = #{title} AND status = 1 LIMIT 1")
    CouponInfo selectUserActiveByTitle(@Param("userId") Long userId, @Param("title") String title);

    @Select("SELECT id, name AS title, description AS condition_text, threshold_amount, discount_amount, expire_date, status " +
            "FROM coupon ORDER BY id DESC")
    List<CouponInfo> selectAllCouponTemplates();

    @Insert("INSERT INTO coupon(name, description, threshold_amount, discount_amount, expire_date, status) " +
            "VALUES(#{title}, #{conditionText}, #{thresholdAmount}, #{discountAmount}, #{expireDate}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertCouponTemplate(CouponInfo couponInfo);

    @Update("UPDATE coupon SET name = #{title}, description = #{conditionText}, threshold_amount = #{thresholdAmount}, " +
            "discount_amount = #{discountAmount}, expire_date = #{expireDate}, status = #{status} WHERE id = #{id}")
    int updateCouponTemplate(CouponInfo couponInfo);

    @Update("UPDATE coupon SET status = #{status} WHERE id = #{id}")
    int updateCouponTemplateStatus(@Param("id") Long id, @Param("status") Integer status);
}

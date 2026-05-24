// utils/cloud.js

/**
 * 根据 cloud 文件 ID 列表换取临时 URL
 * @param {Array<string>} fileIds cloud:// 文件 ID
 * @returns {Promise<Object>} { fileID: tempFileURL }
 */
async function getTempFileUrls(fileIds) {
  if (!fileIds || fileIds.length === 0) {
    return {};
  }

  try {
    const res = await wx.cloud.getTempFileURL({
      fileList: fileIds.filter((id) => id && id.startsWith('cloud://'))
    });

    const urlMap = {};
    (res.fileList || []).forEach((file) => {
      if (file.tempFileURL) {
        urlMap[file.fileID] = file.tempFileURL;
      }
    });

    return urlMap;
  } catch (err) {
    console.error('获取临时 URL 失败', err);
    return {};
  }
}

/**
 * 处理商品列表图片（cloud:// -> 临时 URL）
 * @param {Array} goodsList 商品列表
 * @param {Function} setData 页面/组件 setData
 * @param {String} dataKey 数据字段，默认 goodsList
 */
async function processGoodsImages(goodsList, setData, dataKey = 'goodsList') {
  if (!goodsList || goodsList.length === 0) return;

  const fileIds = goodsList
    .map((item) => item.mainImage || item.image)
    .filter((id) => id && id.startsWith('cloud://'));

  if (fileIds.length === 0) return;

  const urlMap = await getTempFileUrls(fileIds);

  const updatedList = goodsList.map((item) => {
    const imageField = item.mainImage || item.image;
    if (imageField && urlMap[imageField]) {
      return {
        ...item,
        mainImage: urlMap[imageField],
        image: urlMap[imageField]
      };
    }
    return item;
  });

  setData({ [dataKey]: updatedList });
}

module.exports = {
  getTempFileUrls,
  processGoodsImages
};

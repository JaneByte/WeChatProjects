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

/**
 * 处理对象内多个图片字段（cloud:// -> 临时 URL）
 * @param {Object} data 对象数据
 * @param {Array<string>} fields 需处理字段
 * @returns {Promise<Object>} 新对象
 */
async function processObjectImages(data, fields = ['icon', 'mainImage', 'image', 'avatar']) {
  if (!data) return data;

  const fileIds = [];
  fields.forEach((field) => {
    if (data[field] && data[field].startsWith('cloud://')) {
      fileIds.push(data[field]);
    }
  });

  if (fileIds.length === 0) return data;

  const urlMap = await getTempFileUrls(fileIds);
  const result = { ...data };

  fields.forEach((field) => {
    if (result[field] && urlMap[result[field]]) {
      result[field] = urlMap[result[field]];
    }
  });

  return result;
}

/**
 * 处理分类图标（cloud:// -> 临时 URL）
 * @param {Array} categoryList 分类列表
 * @param {Function} setData 页面 setData
 * @returns {Promise<Array|undefined>}
 */
async function processCategoryIcons(categoryList, setData) {
  if (!categoryList || categoryList.length === 0) return;

  const fileIds = categoryList
    .map((item) => item.icon)
    .filter((id) => id && id.startsWith('cloud://'));

  if (fileIds.length === 0) return;

  const urlMap = await getTempFileUrls(fileIds);

  const updatedList = categoryList.map((item) => {
    if (item.icon && urlMap[item.icon]) {
      return { ...item, iconUrl: urlMap[item.icon] };
    }
    return { ...item, iconUrl: item.icon };
  });

  setData({ categoryList: updatedList });
  return updatedList;
}

module.exports = {
  getTempFileUrls,
  processGoodsImages,
  processObjectImages,
  processCategoryIcons
};

const CategoryConfig = require('../models/categoryConfig');

const getCategories = async (req, res) => {
  try {
    const categories = await CategoryConfig.find({ isVisible: true }).sort({ order: 1 });
    res.json({ categories });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getAllCategories = async (req, res) => {
  try {
    const categories = await CategoryConfig.find().sort({ order: 1 });
    res.json({ categories });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createCategory = async (req, res) => {
  try {
    const { name, order, isVisible } = req.body;

    const existing = await CategoryConfig.findOne({ name });
    if (existing) {
      return res.status(400).json({ message: 'Category already exists' });
    }

    const maxOrder = await CategoryConfig.findOne().sort({ order: -1 });
    const nextOrder = order !== undefined ? order : (maxOrder ? maxOrder.order + 1 : 0);

    const category = await CategoryConfig.create({
      name,
      order: nextOrder,
      isVisible: isVisible !== undefined ? isVisible : true,
    });

    res.status(201).json({ category });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateCategory = async (req, res) => {
  try {
    const category = await CategoryConfig.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }
    res.json({ category });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteCategory = async (req, res) => {
  try {
    const category = await CategoryConfig.findByIdAndDelete(req.params.id);
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }
    res.json({ message: 'Category deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const reorderCategories = async (req, res) => {
  try {
    const { orderedIds } = req.body;

    if (!Array.isArray(orderedIds)) {
      return res.status(400).json({ message: 'orderedIds must be an array' });
    }

    const updates = orderedIds.map((id, index) =>
      CategoryConfig.findByIdAndUpdate(id, { order: index }, { new: true })
    );

    await Promise.all(updates);

    const categories = await CategoryConfig.find().sort({ order: 1 });
    res.json({ categories });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getCategories,
  getAllCategories,
  createCategory,
  updateCategory,
  deleteCategory,
  reorderCategories,
};

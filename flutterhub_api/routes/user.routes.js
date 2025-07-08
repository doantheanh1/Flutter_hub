const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');

router.get('/search', userController.searchUsers);
router.get('/:idOrEmail', userController.getUserDetail);
router.post('/', userController.createUser);
router.delete('/:idOrEmail', userController.deleteUser);
router.get('/:userId/stats', userController.getUserStats);

module.exports = router; 
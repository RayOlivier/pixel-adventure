bool checkCollision(player, block) {
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = player.width;
  final playerHeight = player.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

// playerX compensating for horizontal flip when moving left
  final fixedPlayerX = player.scale.x < 0 ? playerX - playerWidth : playerX;

// fix playerY for platforms (only collide bottom of player with platform if falling)
  final fixedPlayerY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedPlayerY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedPlayerX < blockX + blockWidth &&
      fixedPlayerX + playerWidth > blockX);
}

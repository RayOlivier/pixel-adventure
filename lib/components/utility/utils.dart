bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

// playerX compensating for horizontal flip when moving left and hitbox
  final fixedPlayerX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;

// fix playerY for platforms (only collide bottom of player with platform if falling)
  final fixedPlayerY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedPlayerY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedPlayerX < blockX + blockWidth &&
      fixedPlayerX + playerWidth > blockX);
}

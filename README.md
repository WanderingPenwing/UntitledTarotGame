# potit message pour le grandd power

je l'ai pas explique dans les commentaires des script, mais j'ai fait un truc qui peux sembler bizarre dans la plupars des scenes :

un sprite qui s'appele view_sprite avec un subviewport qui s'appele view, avec toute la scenne sous le viewport.

Pour la resolution de 160x144, j'ai mis du 640x576 et j'ai dit a godot qu c'est de l'upscale x4. Le pb c'est qu'il affiche quand meme des trucs en full resolution (exemple : le text, et les mouvement subpixel)

Le bidouillage avec le viewport permet d'assurer le pixel perfect

si tu veux tu peux tester dans le prefab gameui, j'ai pas mis le filtre (le texte sera du pixel art et pas d annimations prevues).
Tu peux essayer de faire le setup subviewport + sprite dot la texture est une viewporttexture pour voir que le texte deviendra pixel perfect

Si tu as une methode plus efficace pour le faire hesite pas

Sinon je vais surement bidouiller un shader pour faire du nearest (pour l'instant si unn sprite est en demi pixel, c'est blurry)

On pourra en discuter en voc stv

import 'dart:math' as math;

import 'package:desafio_hostaraguaia/components/constants/constants.dart';
import 'package:desafio_hostaraguaia/components/place_holder.dart';
import 'package:desafio_hostaraguaia/components/extension_string.dart';
import 'package:desafio_hostaraguaia/models/pokemon.dart';
import 'package:desafio_hostaraguaia/stores/pokemon_stores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

mixin AnimatedHeaderMixin on SliverPersistentHeaderDelegate {
  double animation(double shrinkOffset) {
    final diff = maxExtent - shrinkOffset;

    final progress = diff / maxExtent;

    return progress;
  }

  double reverseAnimation(double shrinkOffset) {
    return 1 - animation(shrinkOffset);
  }
}

class PokemonHeader extends SliverPersistentHeaderDelegate
    with AnimatedHeaderMixin {
  PokemonHeader(
    this.pokemon, {
    required this.maxExtent,
  });
  final Pokemon pokemon;

  @override
  double get minExtent => kToolbarHeight * 1.8;
  @override
  final double maxExtent;

  static const _normal = 2.0;

  double _elementOpacity(double animation, {double factor = _normal}) {
    return math.pow(animation, factor) as double;
  }

  double _reverseElementOpacity(double animation, {double factor = _normal}) {
    return 1 - _elementOpacity(animation, factor: factor);
  }

  PokemonApiStore pokemonApiStore = PokemonApiStore();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    pokemonApiStore.getFavorite(pokemon.name!);
    final animation = this.animation(shrinkOffset);
    final reverseAnimation = this.reverseAnimation(shrinkOffset);

    return InkWell(
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          children: [
            _buildShrinkPokemonHeader(
              context,
              animation,
              reverseAnimation,
            ),
            _buildExpandedPokemonHeader(
              context,
              animation,
              reverseAnimation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPokemonHeader(
    BuildContext context,
    double animation,
    double reverseAnimation,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _elementOpacity(
          animation,
        ),
        child: Container(
          color: kRedColor,
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(height: maxExtent),
            child: Padding(
              padding: const EdgeInsets.all(20).copyWith(left: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCloseButton(context),
                  _buildCicleAvatarTitle(),
                  _buildFavoriteButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShrinkPokemonHeader(
    BuildContext context,
    double animation,
    double reverseAnimation,
  ) {
    return Positioned(
      bottom: 0,
      top: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _reverseElementOpacity(
          animation,
        ),
        child: Container(
          color: kRedColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCicleAvatarTitle(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _buildFavoriteButton(
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, bottom: 30),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              height: 20,
              width: 20,
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 33,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCicleAvatarTitle() {
    String? image = pokemon.sprites?.frontDefault;
    String? name = pokemon.name?.capitalize();
    String? type = pokemon.types?.first.type?.name?.capitalize();
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: CircleAvatar(
            radius: kRadius + 2,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              backgroundColor: kRedColor,
              child: image == null ? null : Image.network(image),
              radius: kRadius,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: kFontSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildText(name!, "Raro", true),
              _buildText('Tipo', type, false),
            ],
          ),
        )
      ],
    );
  }

  _buildFavoriteButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Observer(
          builder: (context) => GestureDetector(
            onTap: (() async {
              pokemonApiStore.changeFavorite(pokemon);
            }),
            child: Icon(
              pokemonApiStore.isFavorite ? Icons.star : Icons.star_border,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  _buildText(String staticText, String? text, bool isTitle) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            staticText,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTitle ? kFontSize : 14.0,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w300,
              fontFamily: 'OpenSans',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        PlaceholderContainer(
          size: PlaceholderContainer.textPlaceholder,
          child: text == null
              ? null
              : Text(
                  ' - $text',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTitle ? kFontSize : 14.0,
                    fontWeight: isTitle ? FontWeight.bold : FontWeight.w300,
                    fontFamily: 'OpenSans',
                  ),
                ),
        ),
      ],
    );
  }
}

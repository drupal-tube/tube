<?php

namespace Drupal\tube\Plugin\Tube\OptionalModule;

/**
 * Tube Demo Content.
 *
 * @TubeOptionalModule(
 *   id = "tube_demo",
 *   label = @Translation("Tube Demo Content"),
 *   description = @Translation("Installs demo content to show how Tube works."),
 *   type = "module",
 *   standardlyEnabled = 1,
 *   weight = -1
 * )
 */
class TubeDemo extends AbstractOptionalModule {}

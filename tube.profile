<?php

/**
 * @file
 * Enables modules and site configuration for a tube site installation.
 */

use Drupal\Core\Form\FormStateInterface;
use Drupal\user\Entity\User;

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function tube_form_install_configure_form_alter(&$form, FormStateInterface $form_state) {
  // Add a value as example that one can choose an arbitrary site name.
  $form['site_information']['site_name']['#placeholder'] = t('Tube');
}

/**
 * Implements hook_install_tasks().
 */
function tube_install_tasks(&$install_state) {
  $tasks = [];
  if (empty($install_state['config_install_path'])) {
    $tasks['tube_module_configure_form'] = [
      'display_name' => t('Configure additional modules'),
      'type' => 'form',
      'function' => 'Drupal\tube\Installer\Form\ModuleConfigureForm',
    ];
    $tasks['tube_module_install'] = [
      'display_name' => t('Install additional modules'),
      'type' => 'batch',
    ];
  }
  $tasks['tube_finish_installation'] = [
    'display_name' => t('Finish installation'),
  ];
  return $tasks;
}

/**
 * Installs the tube modules in a batch.
 *
 * @param array $install_state
 *   The install state.
 *
 * @return array
 *   A batch array to execute.
 */
function tube_module_install(array &$install_state) {

  $modules = $install_state['tube_additional_modules'];

  $batch = [];
  if ($modules) {
    $operations = [];
    foreach ($modules as $module) {
      $operations[] = [
        '_tube_install_module_batch',
        [[$module], $module, $install_state['form_state_values']],
      ];
    }

    $batch = [
      'operations' => $operations,
      'title' => t('Installing additional modules'),
      'error_message' => t('The installation has encountered an error.'),
    ];
  }

  return $batch;
}

/**
 * Implements callback_batch_operation().
 *
 * Performs batch installation of modules.
 */
function _tube_install_module_batch($module, $module_name, $form_values, &$context) {
  set_time_limit(0);

  $optionalModulesManager = \Drupal::service('plugin.manager.tube.optional_modules');

  try {
    $definition = $optionalModulesManager->getDefinition($module_name);
    if ($definition['type'] == 'module') {
      \Drupal::service('module_installer')->install($module, TRUE);
    }
    elseif ($definition['type'] == 'theme') {
      \Drupal::service('theme_installer')->install($module, TRUE);
    }

    $instance = $optionalModulesManager->createInstance($module_name);
    $instance->submitForm($form_values);
  }
  catch (\Exception $e) {

  }

  $context['results'][] = $module;
  $context['message'] = t('Installed %module_name modules.', ['%module_name' => $module_name]);
}

/**
 * Finish Tube installation process.
 *
 * @param array $install_state
 *   The install state.
 *
 * @throws \Drupal\Core\Entity\EntityStorageException
 */
function tube_finish_installation(array &$install_state) {
  \Drupal::service('config.installer')->installOptionalConfig();

  // Assign user 1 the "administrator" role.
  $user = User::load(1);
  $user->roles[] = 'administrator';
  $user->save();
}

/**
 * Implements hook_page_attachments().
 */
function tube_page_attachments(array &$attachments) {

  foreach ($attachments['#attached']['html_head'] as &$html_head) {

    $name = $html_head[1];

    if ($name == 'system_meta_generator') {
      $tag = &$html_head[0];
      $tag['#attributes']['content'] = 'Drupal 8 (Tube | https://www.drupal.org/project/tube)';
    }
  }
}

/**
 * Implements hook_library_info_alter().
 */
function tube_toolbar_alter(&$items) {
  if (!empty($items['admin_toolbar_tools'])) {
    // $items['admin_toolbar_tools']['#attached']['library'][] = 'tube/toolbar.icon';
  }
}

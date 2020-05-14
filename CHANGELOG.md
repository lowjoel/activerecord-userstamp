 # Changelog

 ## 3.0.7 (05-5-2020)
  * Yuhki Tokue       - Allow blank current-user

 ## 3.0.6 (10-5-2018)
  * Yuhki Tokue       - Support Rails 6.0.
  * Yuhki Tokue       - Stampable available with soft-deleted users

 ## 3.0.5 (22-8-2017)
  * Jonathan Putney   - Support Rails 5.0.
  * Joel Low          - Add additional combinations to Travis build matrix.
  * Joel Low          - Defer association definitions until the schema is loaded.
  * Joel Low          - Respect custom stamper definitions.

 ## 3.0.4 (14-7-2015)
  * Joel Low          - Allow using ActiveRecord-Userstamp with anonymous models (e.g. some
                        `has_and_belongs_to_many` join tables.)

 ## 3.0.3 (14-7-2015)
  * Joel Low          - Allow using ActiveRecord-Userstamp with generated tables (e.g.
                        `has_and_belongs_to_many` join tables.)

 ## 3.0.2 (12-7-2015)
  * Joel Low          - Depending on what was set to a stamper (ID or record object), the
                        association ID or association setter is used to assign the
                        creator/updater/deleter attributes. This only applies if the attributes
                        end with `_id`; otherwise the attribute would be used verbatim (e.g. the
                        compatibility mode `created_by`).
  * Joel Low          - Provide a `with_stamper` method to specify the stamper for a given
                        stamper class during the execution of the block.
  * Joel Low          - Ensure that the `set_stamper` and `reset_stamper` calls from the
                        controller are always paired so that the stamper state is always properly
                        restored. `set_stamper` and `reset_stamper` is now deprecated and will be
                        removed in ActiveRecord::Userstamp 3.1 and replaced with a single
                        `with_stamper` `around_action` callback.

 ## 3.0.1 (11-7-2015)
  * Joel Low          - Only declare the creator/updater/deleter associations when the table has
                        the attribute columns. If the columns cannot be determined (e.g. if the
                        table has not been defined, such as during tests), then the model would
                        need to explicitly call `stampable`.

 ## 3.0.0 (10-7-2015)
  * Joel Low          - Remove `compatibility_mode`. Use the `creator_attribute`,
                        `updater_attribute`, and `deleter_attribute` configuration options instead.
  * Joel Low          - The table definition migration helper should follow the gem configuration
                        when generating column names.
  * Joel Low          - When deciding whether to generate a `deleter_id` column, check the gem
                        configuration for the `deleter_attribute` configuration option instead of
                        relying on the user to specify in every migration.
  * Joel Low          - Remove the `deleter` option from the `stampable` model declaration.
  * Joel Low          - Remove the `creator_attribute`, `updater_attribute`, and `deleter_attribute`
                        options from the `stampable` model declaration. All models will follow
                        the gem configuration.
  * Joel Low          - Added the `default_stamper` configuration option. The controller will
                        automatically stamp using that model.
  * Joel Low          - Additional attributes passed to `stampable` would be passed to the
                        underlying `belongs_to` association.
  * Joel Low          - Declare the creator/updater/deleter setter callbacks directly in
                        `ActiveRecord::Base`. So now, all models will automatically be stamped
                        when the creator/updater/deleter attributes are present. This mirrors
                        `ActiveRecord::Timestamp` behaviour.
  * Joel Low          - Automatically declare the creator/updater/deleter associations on every
                        model. To add additional configuration options, simply call `stampable`.
                        This can be called multiple times per model; the last call takes effect.
  * Joel Low          - Remove support for `serialized_attributes`. It will be removed in Rails 5.

 ## 2.1.1 (9-7-2015)

  * Chris Hilton      - Only set updater attribute if the record has changed or contains a
                        serialized attribute.
  * Chris Hilton      - Support `:with_deleted` in the `stampable` declaration.
  * Chris Hilton      - Only set the creator attribute if it is blank.
  * Chris Branson     - Fix deprecation warning in `serialized_attributes`.
  * Joel Low          - Trigger the updater/creator stamping before saving, so that the correct
                        users are stamped even if validation was not run.
  * Joel Low          - Allow extra parameters to be passed to the migration helpers.

## 2.1.0 (28-3-2014)
  * Thomas von Deyen  - Do not automatically make every class stampable.

## 2.0.2 (11-8-2011)
  * Chris Hilton      - Set the creator/updater attributes before validation, so that they can
                        be checked as part of validations.
  * Alex              - Specify that the stampable class is camelized from the given symbol,
                        not just capitalized, to follow ActiveRecord convention.
## 2.0.1 (8-10-2010)
  * Michael Grosser   -  Make stampable define the deleter association and before filter whenever
                         a :deleter_attribute has been passed in options, or :deleter => true is
                         passed, or Caboose::Acts::Paranoid is defined. This makes :deleter
                         functionality useable to people who aren't use acts_as_paranoid.
  * Michael Grosser   -  do not leave record_userstamp turned on when an exception occurs inside
                         the `without_stamps` block

## 2.0 (2-17-2008)
  * Ben Wyrosdick    - Added a migration helper that gives migration scripts a <tt>userstamps</tt>
                       method.
  * Marshall Roch    - Stamping can be temporarily turned off using the 'without_stamps' class
                       method.
    Example:
      Post.without_stamps do
        post = Post.find(params[:id])
        post.update_attributes(params[:post])
        post.save
      end

  * Models that should receive updates made by 'stampers' now use the acts_as_stampable class
    method. This sets up the belongs_to relationships and also injects private methods for use by
    the individual callback filter methods.

  * Models that are responsible for updating now use the acts_as_stamper class method. This
    injects the stamper= and stamper methods that are thread safe and should be updated per
    request by a controller.

  * The Userstamp module is now meant to be included with one of your project's controllers (the
    Application Controller is recommended). It creates a before filter called 'set_stampers' that
    is responsible for setting all the current Stampers.

## 1.0 (01-18-2006)
  * Initial Release

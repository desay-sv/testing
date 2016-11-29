/* eslint-disable */
((global) => {

  class IssuableBulkActions {
    constructor({ container, form, issues } = {}) {
      this.form = form || IssuableBulkActions.getElement('.bulk-update');
      this.$labelDropdown = this.form.find('.js-label-select');
      this.issues = issues || IssuableBulkActions.getElement('.issues-list .issue');
      this.form.data('bulkActions', this);
      this.willUpdateLabels = false;
      this.bindEvents();
      // Fixes bulk-assign not working when navigating through pages
      Issuable.initChecks();
    }

    bindEvents() {
      return this.form.off('submit').on('submit', this.onFormSubmit.bind(this));
    }

    onFormSubmit(e) {
      e.preventDefault();
      return this.submit();
    }

    submit() {
      const _this = this;
      const xhr = $.ajax({
        url: this.form.attr('action'),
        method: this.form.attr('method'),
        dataType: 'JSON',
        data: this.getFormDataAsObject()
      });
      xhr.done(() => window.location.reload());
      xhr.fail(() => new Flash("Issue update failed"));
      return xhr.always(this.onFormSubmitAlways.bind(this));
    }

    onFormSubmitAlways() {
      return this.form.find('[type="submit"]').enable();
    }

    getSelectedIssues() {
      return this.issues.has('.selected_issue:checked');
    }

    getLabelsFromSelection() {
      const labels = [];
      this.getSelectedIssues().map(function() {
        const labelsData = $(this).data('labels');
        if (labelsData) {
          return labelsData.map(function(labelId) {
            if (labels.indexOf(labelId) === -1) {
              return labels.push(labelId);
            }
          });
        }
      });
      return labels;
    }


    /**
     * Will return only labels that were marked previously and the user has unmarked
     * @return {Array} Label IDs
     */

    getUnmarkedIndeterminedLabels() {
      const result = [];
      const labelsToKeep = this.$labelDropdown.data('indeterminate');

      this.getLabelsFromSelection().forEach((id) => {
        if (labelsToKeep.indexOf(id) === -1) {
          result.push(id);
        }
      });

      return result;
    }


    /**
     * Simple form serialization, it will return just what we need
     * Returns key/value pairs from form data
     */

    getFormDataAsObject() {
      const formData = {
        update: {
          state_event: this.form.find('input[name="update[state_event]"]').val(),
          assignee_id: this.form.find('input[name="update[assignee_id]"]').val(),
          milestone_id: this.form.find('input[name="update[milestone_id]"]').val(),
          issuable_ids: this.form.find('input[name="update[issuable_ids]"]').val(),
          subscription_event: this.form.find('input[name="update[subscription_event]"]').val(),
          add_label_ids: [],
          remove_label_ids: []
        }
      };
      if (this.willUpdateLabels) {
        formData.update.add_label_ids = this.$labelDropdown.data('marked');
        formData.update.remove_label_ids = this.$labelDropdown.data('unmarked');
      }
      return formData;
    }

    setOriginalDropdownData() {
      $('.bulk-update .js-label-select').data('marked', IssuableBulkActions.getOriginalMarkedIds());
      $('.bulk-update .js-label-select').data('indeterminate', IssuableBulkActions.getOriginalIndeterminateIds());
      $('.bulk-update .js-label-select').data('common', IssuableBulkActions.getOriginalCommonIds());
    }

    // FROM ORIGINAL SELECTION
    static getOriginalCommonIds() {
      let labelIds = [];

      this.getElement('.selected_issue:checked').each((i, el) => {
        issueLabels = this.getElement("#issue_" + el.dataset.id).data('labels');
        labelIds.push(issueLabels);
      });
      return _.intersection.apply(this, labelIds);
    }

    // FROM ORIGINAL SELECTION
    static getOriginalMarkedIds() {
      var label_ids;
      label_ids = [];
      $('.selected_issue:checked').each(function(i, el) {
        var issue_id;
        issue_id = $(el).data('id');
        return label_ids.push($("#issue_" + issue_id).data('labels'));
      });
      let val = _.intersection.apply(_, label_ids);
      return val;
    }

    // FROM ORIGINAL SELECTION
    static getOriginalIndeterminateIds() {
      let uniqueIds = [];
      let labelIds = [];
      let issueLabels = [];

      // Collect unique label IDs for all checked issues
      this.getElement('.selected_issue:checked').each((i, el) => {
        issueLabels = this.getElement("#issue_" + el.dataset.id).data('labels');
        issueLabels.forEach((labelId) => {
          // Store unique IDs
          if (uniqueIds.indexOf(labelId) === -1) {
            uniqueIds.push(labelId);
          }
        });
        // Store array of IDs per issue
        labelIds.push(issueLabels);
      });
      // Add uniqueIds to add it as argument for _.intersection
      labelIds.unshift(uniqueIds);
      // Return IDs that are present but not in all selected issues
      let val = _.difference(uniqueIds, _.intersection.apply(this, labelIds));
      return val;
    }

    static getElement(selector) {
      return $('.content').find(selector);
    }
  }

  global.IssuableBulkActions = IssuableBulkActions;

})(window.gl || (window.gl = {}));

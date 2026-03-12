sap.ui.define([
  "sap/ui/core/mvc/ControllerExtension",
  "sap/m/Dialog",
  "sap/m/DialogType",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/Button",
  "sap/m/ButtonType",
  "sap/m/MessageToast",
  "sap/m/MessageBox"
], function (
  ControllerExtension,
  Dialog,
  DialogType,
  Label,
  Input,
  Button,
  ButtonType,
  MessageToast,
  MessageBox
) {
  "use strict";

  return ControllerExtension.extend("cpq.indexation.indexationui.ext.objectPage.ObjectPageExt", {
    onApplyIndexationPress: function () {
      const oView = this.base.getView();
      const oResourceBundle = oView.getModel("i18n").getResourceBundle();

      if (!this._oApplyDialog) {
        this._oPercentageInput = new Input({
          type: "Number",
          width: "100%",
          placeholder: "5"
        });

        this._oApplyDialog = new Dialog({
          title: oResourceBundle.getText("applyIndexationDialogTitle"),
          type: DialogType.Standard,
          contentWidth: "25rem",
          content: [
            new Label({
              text: oResourceBundle.getText("applyIndexationPercentageLabel"),
              labelFor: this._oPercentageInput
            }),
            this._oPercentageInput
          ],
          beginButton: new Button({
            text: oResourceBundle.getText("applyIndexationConfirm"),
            type: ButtonType.Emphasized,
            press: async function () {
              const sValue = this._oPercentageInput.getValue();
              const nPercentage = Number(sValue);

              if (!Number.isFinite(nPercentage) || nPercentage < 0 || nPercentage > 100) {
                MessageBox.warning(oResourceBundle.getText("applyIndexationInvalid"));
                return;
              }

              const oContext = oView.getBindingContext();
              if (!oContext) {
                MessageBox.error("No quote context found on the object page.");
                return;
              }

              try {
                const oModel = oView.getModel();

                // Bound action on the current quote
                const sActionPath = `${oContext.getPath()}/IndexationService.ApplyIndexation(...)`;
                const oOperation = oModel.bindContext(sActionPath);

                oOperation.setParameter("percentage", nPercentage);

                await oOperation.execute();

                const oResultContext = oOperation.getBoundContext();
                const oResult = oResultContext ? oResultContext.getObject() : null;

                this._oApplyDialog.close();
                this._oPercentageInput.setValue("");

                if (oResult && oResult.newQuoteId) {
                  MessageToast.show(
                    oResourceBundle.getText("applyIndexationSuccess", [oResult.newQuoteId])
                  );

                  // Navigate to the new quote object page
                  this.base.getExtensionAPI().routing.navigateToRoute("QuotesObjectPage", {
                    key: String(oResult.newQuoteId)
                  });
                } else {
                  MessageToast.show(oResourceBundle.getText("applyIndexationNoResult"));
                }
              } catch (oError) {
                MessageBox.error(
                  `${oResourceBundle.getText("applyIndexationError")}\n\n${oError.message || oError}`
                );
              }
            }.bind(this)
          }),
          endButton: new Button({
            text: oResourceBundle.getText("applyIndexationCancel"),
            press: function () {
              this._oApplyDialog.close();
              this._oPercentageInput.setValue("");
            }.bind(this)
          })
        });

        oView.addDependent(this._oApplyDialog);
      }

      this._oApplyDialog.open();
    }
  });
});
sap.ui.define([
  "sap/m/Dialog",
  "sap/m/DialogType",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/Button",
  "sap/m/ButtonType",
  "sap/m/MessageToast",
  "sap/m/MessageBox"
], function (
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

  let oApplyDialog;
  let oPercentageInput;

  return {
    onApplyIndexationPress: async function (oContext) {
      if (!oContext) {
        MessageBox.error("No quote context found.");
        return;
      }

      const oModel = oContext.getModel();
      const oResourceBundle = sap.ui.getCore().getLibraryResourceBundle
        ? null
        : null;

      const getText = function (key, args) {
        const oI18nModel = sap.ui.getCore().byId(
          sap.ui.getCore().getCurrentFocusedControlId()
        )?.getModel?.("i18n");

        if (oI18nModel) {
          return oI18nModel.getResourceBundle().getText(key, args);
        }

        const fallback = {
          applyIndexationDialogTitle: "Apply Indexation",
          applyIndexationPercentageLabel: "Percentage",
          applyIndexationConfirm: "Apply",
          applyIndexationCancel: "Cancel",
          applyIndexationSuccess: "Indexation applied. New revision {0}.",
          applyIndexationNoResult: "Indexation applied, but no new quote ID was returned.",
          applyIndexationInvalid: "Enter a percentage between 0 and 100.",
          applyIndexationError: "Apply Indexation failed."
        };

        let text = fallback[key] || key;
        if (args && args.length) {
          args.forEach((arg, index) => {
            text = text.replace(`{${index}}`, arg);
          });
        }
        return text;
      };

      if (!oApplyDialog) {
        oPercentageInput = new Input({
          type: "Number",
          width: "100%",
          placeholder: "5"
        });

        oApplyDialog = new Dialog({
          title: getText("applyIndexationDialogTitle"),
          type: DialogType.Standard,
          contentWidth: "25rem",
          content: [
            new Label({
              text: getText("applyIndexationPercentageLabel"),
              labelFor: oPercentageInput
            }),
            oPercentageInput
          ]
        });
      }

      oApplyDialog.removeAllButtons();

      oApplyDialog.addButton(new Button({
        text: getText("applyIndexationConfirm"),
        type: ButtonType.Emphasized,
        press: async function () {
          const nPercentage = Number(oPercentageInput.getValue());

          if (!Number.isFinite(nPercentage) || nPercentage < 0 || nPercentage > 100) {
            MessageBox.warning(getText("applyIndexationInvalid"));
            return;
          }

          try {
            const sActionPath = `${oContext.getPath()}/IndexationService.ApplyIndexation(...)`;
            const oOperation = oModel.bindContext(sActionPath);

            oOperation.setParameter("percentage", nPercentage);

            await oOperation.execute();

            const oResultContext = oOperation.getBoundContext();
            const oResult = oResultContext ? oResultContext.getObject() : null;

            oApplyDialog.close();
            oPercentageInput.setValue("");

            if (oResult && oResult.newQuoteId) {
              MessageToast.show(getText("applyIndexationSuccess", [String(oResult.newQuoteId)]));

              // navigatie naar de nieuwe quote
              const sHash = `#/Quotes(${oResult.newQuoteId})`;
              window.location.hash = sHash;
            } else {
              MessageToast.show(getText("applyIndexationNoResult"));
            }
          } catch (oError) {
            MessageBox.error(
              `${getText("applyIndexationError")}\n\n${oError.message || oError}`
            );
          }
        }
      }));

      oApplyDialog.addButton(new Button({
        text: getText("applyIndexationCancel"),
        press: function () {
          oApplyDialog.close();
          oPercentageInput.setValue("");
        }
      }));

      oApplyDialog.open();
    }
  };
});
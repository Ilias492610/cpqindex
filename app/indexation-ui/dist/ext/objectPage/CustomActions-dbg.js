sap.ui.define([
  "sap/m/Dialog",
  "sap/m/DialogType",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/Button",
  "sap/m/ButtonType",
  "sap/m/MessageToast",
  "sap/m/MessageBox",
  "sap/m/Text",
  "sap/m/Table",
  "sap/m/Column",
  "sap/m/ColumnListItem",
  "sap/m/ObjectNumber",
  "sap/m/VBox",
  "sap/m/HBox",
  "sap/m/Title",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (
  Dialog,
  DialogType,
  Label,
  Input,
  Button,
  ButtonType,
  MessageToast,
  MessageBox,
  Text,
  Table,
  Column,
  ColumnListItem,
  ObjectNumber,
  VBox,
  HBox,
  Title,
  Filter,
  FilterOperator
) {
  "use strict";

  let oPercentageDialog;
  let oPercentageInput;

  function getErrorMessage(oError) {
    try {
      const sRaw = oError?.message || String(oError);

      if (sRaw.includes("{")) {
        const sJson = sRaw.substring(sRaw.indexOf("{"));
        const oParsed = JSON.parse(sJson);
        return (
          oParsed?.error?.message ||
          oParsed?.message ||
          sRaw
        );
      }

      return sRaw;
    } catch (e) {
      return oError?.message || String(oError);
    }
  }

  function formatNumber(v) {
    const n = Number(v);
    if (!Number.isFinite(n)) {
      return "0.000000";
    }
    return n.toFixed(6);
  }

  function formatCurrency(v, sCurrency) {
    return sCurrency
      ? `${formatNumber(v)} ${sCurrency}`
      : formatNumber(v);
  }

  async function loadPreviewContext(oModel, sPreviewId) {
    const oListBinding = oModel.bindList(
      "/Previews",
      undefined,
      undefined,
      [new Filter("ID", FilterOperator.EQ, sPreviewId)],
      { $expand: "items" }
    );

    const aContexts = await oListBinding.requestContexts(0, 1);

    if (!aContexts || !aContexts.length) {
      throw new Error("Preview kon niet worden geladen.");
    }

    return aContexts[0];
  }

  function createSummaryBlock(oPreview) {
    const sCurrency = oPreview.currencyCode || "";

    return new VBox({
      width: "100%",
      items: [
        new Title({ text: `Preview voor quote ${oPreview.quoteNumber || oPreview.quoteId}` }),
        new HBox({
          justifyContent: "SpaceBetween",
          items: [
            new VBox({
              items: [
                new Text({ text: `Percentage: ${formatNumber(oPreview.percentage)} %` }),
                new Text({ text: `Aantal items: ${oPreview.itemCount}` }),
                new Text({ text: `Status: ${oPreview.status}` })
              ]
            }),
            new VBox({
              items: [
                new Text({ text: `Origineel totaal: ${formatCurrency(oPreview.originalTotal, sCurrency)}` }),
                new Text({ text: `Preview totaal: ${formatCurrency(oPreview.previewTotal, sCurrency)}` }),
                new Text({ text: `Verschil: ${formatCurrency(oPreview.deltaTotal, sCurrency)}` })
              ]
            })
          ]
        })
      ]
    });
  }

  function createItemsTable(oPreview) {
    const aItems = oPreview.items || [];

    return new Table({
      width: "100%",
      sticky: ["ColumnHeaders"],
      columns: [
        new Column({ header: new Text({ text: "Item" }) }),
        new Column({ header: new Text({ text: "Product" }) }),
        new Column({ header: new Text({ text: "Qty" }) }),
        new Column({ header: new Text({ text: "Old Net Price" }) }),
        new Column({ header: new Text({ text: "New Net Price" }) }),
        new Column({ header: new Text({ text: "Old Extended" }) }),
        new Column({ header: new Text({ text: "New Extended" }) }),
        new Column({ header: new Text({ text: "Delta" }) })
      ],
      items: aItems.map(function (oItem) {
        return new ColumnListItem({
          cells: [
            new Text({ text: String(oItem.itemNumber || "") }),
            new Text({ text: oItem.productName || oItem.description || "" }),
            new Text({ text: formatNumber(oItem.quantity) }),
            new ObjectNumber({
              number: formatNumber(oItem.originalNetPrice),
              unit: oItem.currencyCode || ""
            }),
            new ObjectNumber({
              number: formatNumber(oItem.previewNetPrice),
              unit: oItem.currencyCode || ""
            }),
            new ObjectNumber({
              number: formatNumber(oItem.originalExtendedAmount),
              unit: oItem.currencyCode || ""
            }),
            new ObjectNumber({
              number: formatNumber(oItem.previewExtendedAmount),
              unit: oItem.currencyCode || ""
            }),
            new ObjectNumber({
              number: formatNumber(oItem.deltaAmount),
              unit: oItem.currencyCode || ""
            })
          ]
        });
      })
    });
  }

  function createPreviewDialog(oModel, oQuoteContext, oPreviewContext) {
    const oPreview = oPreviewContext.getObject();

    const oDialog = new Dialog({
      title: "Indexation Preview",
      type: DialogType.Standard,
      contentWidth: "90%",
      contentHeight: "80%",
      stretchOnPhone: true,
      draggable: true,
      resizable: true,
      content: [
        createSummaryBlock(oPreview),
        createItemsTable(oPreview)
      ]
    });

    oDialog.addButton(new Button({
      text: "Bevestigen",
      type: ButtonType.Emphasized,
      press: async function () {
        try {
          oDialog.setBusy(true);

          const oAction = oModel.bindContext(
            `${oPreviewContext.getPath()}/IndexationService.Confirm(...)`
          );

          await oAction.execute();

          const oResultContext = oAction.getBoundContext();
          const oResult = oResultContext ? oResultContext.getObject() : null;

          oDialog.close();
          oDialog.destroy();

          if (oResult && oResult.newQuoteId) {
            MessageToast.show(`Indexation bevestigd. Nieuwe quote: ${oResult.newQuoteId}`);
            oModel.refresh();
            window.location.hash = `#/Quotes(${oResult.newQuoteId})`;
          } else {
            MessageToast.show("Indexation bevestigd.");
            oModel.refresh();
          }
        } catch (oError) {
          MessageBox.error(`Bevestigen mislukt.\n\n${getErrorMessage(oError)}`);
        } finally {
          oDialog.setBusy(false);
        }
      }
    }));

    oDialog.addButton(new Button({
      text: "Annuleren",
      press: async function () {
        try {
          oDialog.setBusy(true);

          const oAction = oModel.bindContext(
            `${oPreviewContext.getPath()}/IndexationService.Cancel(...)`
          );

          await oAction.execute();

          oDialog.close();
          oDialog.destroy();

          MessageToast.show("Preview geannuleerd.");
        } catch (oError) {
          MessageBox.error(`Annuleren mislukt.\n\n${getErrorMessage(oError)}`);
        } finally {
          oDialog.setBusy(false);
        }
      }
    }));

    return oDialog;
  }

  return {
    onApplyIndexationPress: async function (oContext) {
      if (!oContext) {
        MessageBox.error("No quote context found.");
        return;
      }

      const oModel = oContext.getModel();

      if (!oPercentageDialog) {
        oPercentageInput = new Input({
          type: "Number",
          width: "100%",
          placeholder: "5"
        });

        oPercentageDialog = new Dialog({
          title: "Create Preview",
          type: DialogType.Standard,
          contentWidth: "25rem",
          content: [
            new Label({
              text: "Percentage",
              labelFor: oPercentageInput
            }),
            oPercentageInput
          ]
        });
      }

      oPercentageDialog.removeAllButtons();

      oPercentageDialog.addButton(new Button({
        text: "Maak preview",
        type: ButtonType.Emphasized,
        press: async function () {
          const nPercentage = Number(oPercentageInput.getValue());

          if (!Number.isFinite(nPercentage) || nPercentage < 0 || nPercentage > 100) {
            MessageBox.warning("Geef een percentage tussen 0 en 100 in.");
            return;
          }

          try {
            oPercentageDialog.setBusy(true);

            const sActionPath = `${oContext.getPath()}/IndexationService.CreatePreview(...)`;
            const oOperation = oModel.bindContext(sActionPath);

            oOperation.setParameter("percentage", nPercentage);
            await oOperation.execute();

            const oResultContext = oOperation.getBoundContext();
            const oResult = oResultContext ? oResultContext.getObject() : null;

            if (!oResult || !oResult.previewId) {
              throw new Error("Geen previewId ontvangen van de backend.");
            }

            const oPreviewContext = await loadPreviewContext(oModel, oResult.previewId);

            oPercentageDialog.close();
            oPercentageInput.setValue("");

            const oPreviewDialog = createPreviewDialog(oModel, oContext, oPreviewContext);
            oPreviewDialog.open();
          } catch (oError) {
            MessageBox.error(`Preview maken mislukt.\n\n${getErrorMessage(oError)}`);
          } finally {
            oPercentageDialog.setBusy(false);
          }
        }
      }));

      oPercentageDialog.addButton(new Button({
        text: "Sluiten",
        press: function () {
          oPercentageDialog.close();
          oPercentageInput.setValue("");
        }
      }));

      oPercentageDialog.open();
    }
  };
});
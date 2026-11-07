document.addEventListener("DOMContentLoaded", function () {
  const optionTypeSelects = document.querySelectorAll("select[data-option-index]");
  optionTypeSelects.forEach((select) => select.addEventListener("change", onSelection));
  if (optionTypeSelects.length > 0) {
    setTimeout(() => { onSelection({ target: optionTypeSelects[0] }); }, 1);
  }
});

function onSelection(event) {
  const optionIndex = event.target.dataset.optionIndex;
  const nextSelect = document.querySelector(`select[data-option-index="${parseInt(optionIndex, 10) + 1}"]`);
  if (nextSelect) {
    updateOptions(nextSelect, optionIndex);
  }
  selectVariant();
}

function updateStockView(status) {
  if (status) {
    this.stockIndicatorTarget.classList.add("d-hide");
    this.cartButtonTarget.disabled = false;
  } else {
    this.stockIndicatorTarget.classList.remove("d-hide");
    this.cartButtonTarget.disabled = true;
  }
}

function updateOptions(nextSelect, optionIndex) {
  const nextOptionValues = this.nextOptionValues(optionIndex);

  [...nextSelect.options].forEach((option) => {
    const available = nextOptionValues.includes(parseInt(option.value, 10));
    option.disabled = !available;
    option.hidden = !available;
  });

  if (nextSelect.selectedOptions[0]?.disabled) {
    const firstAvailable = [...nextSelect.options].find((option) => !option.disabled);
    if (firstAvailable) { nextSelect.value = firstAvailable.value; }
  }
  onSelection({ target: nextSelect });
}

function nextOptionValues(optionIndex) {
  const values = [];
  const variantOptionsTargets = document.querySelectorAll('.product-variants__list > li > input');
  variantOptionsTargets.forEach((option) => {
    const optionValueIds = JSON.parse(option.attributes["data-option-value-ids"].value);
    const selectedOptionIds = this.currentSelection();
    let matched = true;
    for (let i = 0; i <= optionIndex; i += 1) {
      if (optionValueIds[i] !== selectedOptionIds[i]) {
        matched = false;
        break;
      }
    }
    if (matched) {
      values.push(optionValueIds[parseInt(optionIndex, 10) + 1]);
    }
  });
  return values;
}

function updateView(variant) {
  document.querySelector('#product-price').innerHTML = variant.dataset.price;
}

function selectVariant() {
  this.variant = document.querySelector(`[data-option-value-ids="${JSON.stringify(this.currentSelection())}"]`);
  if (this.variant) {
    this.variant.click();
    this.updateView(this.variant);
  } else {
    this.priceTarget.innerText = "Not found, please select all optionTypeSelector";
  }
}

function currentSelection() {
  let i = 0;
  const selectionArr = [];
  while (document.querySelector(`[data-option-index="${i}"]`)) {
    selectionArr.push(parseInt(document.querySelector(`[data-option-index="${i}"]`).value, 10));
    i += 1;
  }
  return selectionArr;
}

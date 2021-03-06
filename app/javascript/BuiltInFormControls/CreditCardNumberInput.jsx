import React from 'react';
import PropTypes from 'prop-types';
import Payment from 'payment';
import classNames from 'classnames';

const CARD_TYPE_ICONS = {
  visa: 'fa-cc-visa',
  mastercard: 'fa-cc-mastercard',
  amex: 'fa-cc-amex',
  dinersclub: 'fa-cc-dinersclub',
  discover: 'fa-cc-discover',
  jcb: 'fa-cc-jcb',
  unknown: 'fa-credit-card',
};

class CreditCardNumberInput extends React.Component {
  static propTypes = {
    id: PropTypes.string.isRequired,
    value: PropTypes.string,
  };

  static defaultProps = {
    value: '',
  };

  getIconClass = () => {
    let iconClass;
    let colorClass;
    const cardNumber = this.props.value;

    if (cardNumber && cardNumber.length > 0) {
      const cardType = Payment.fns.cardType(cardNumber);

      if (cardType) {
        iconClass = CARD_TYPE_ICONS[cardType] || CARD_TYPE_ICONS.unknown;

        const cardTypeObject = Payment.getCardArray().find(card => card.type === cardType);
        if (cardTypeObject.length.includes(cardNumber.replace(/\s/g, '').length)) {
          if (Payment.fns.validateCardNumber(cardNumber)) {
            colorClass = 'text-success';
          } else {
            iconClass = 'fa-exclamation-triangle';
            colorClass = 'text-danger';
          }
        }
      } else {
        iconClass = CARD_TYPE_ICONS.unknown;
      }
    } else {
      iconClass = CARD_TYPE_ICONS.unknown;
    }

    return classNames('fa', iconClass, colorClass);
  }

  render() {
    return (
      <div className="form-group">
        <label htmlFor={this.props.id} className="control-label">Credit card number</label>
        <div className="input-group">
          <input
            type="tel"
            className="form-control"
            placeholder="•••• •••• •••• ••••"
            {...this.props}
          />
          <div className="input-group-append">
            <span className="input-group-text"><i className={this.getIconClass()} /></span>
          </div>
        </div>
      </div>
    );
  }
}

export default CreditCardNumberInput;

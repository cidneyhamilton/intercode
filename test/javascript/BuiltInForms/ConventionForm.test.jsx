import React from 'react';
import { mount } from 'enzyme';
import moment from 'moment-timezone';
import Datetime from 'react-datetime';
import BootstrapFormCheckbox from '../../../app/javascript/BuiltInFormControls/BootstrapFormCheckbox';
import BootstrapFormInput from '../../../app/javascript/BuiltInFormControls/BootstrapFormInput';
import ConventionForm from '../../../app/javascript/BuiltInForms/ConventionForm';
import ScheduledValueEditor from '../../../app/javascript/BuiltInFormControls/ScheduledValueEditor';
import TimezoneSelect from '../../../app/javascript/BuiltInFormControls/TimezoneSelect';

describe('ConventionForm', () => {
  const defaultInitialConvention = {
    starts_at: '',
    ends_at: '',
    name: '',
    domain: '',
    timezone_name: '',
    accepting_proposals: false,
    registrations_frozen: false,
    show_schedule: 'no',
    maximum_event_signups: {
      timespans: [
        { start: null, finish: null, value: 'unlimited' },
      ],
    },
    maximum_tickets: null,
  };

  const renderConventionForm = (props, initialConventionProps) => mount((
    <ConventionForm
      initialConvention={{ ...defaultInitialConvention, ...initialConventionProps }}
      saveConvention={() => {}}
      {...props}
    />
  ));

  test('it renders the given values', () => {
    const now = moment.tz({}, 'UTC').toISOString();
    const component = renderConventionForm({}, {
      starts_at: now,
      ends_at: now,
      name: 'myName',
      domain: 'myDomain',
      timezone_name: 'UTC',
      accepting_proposals: true,
      registrations_frozen: true,
      show_schedule: 'gms',
      maximum_event_signups: {
        timespans: [
          { start: null, finish: now, value: 'not_yet' },
          { start: now, finish: null, value: 'unlimited' },
        ],
      },
      maximum_tickets: 100,
    });

    expect(component.find(Datetime).at(0).prop('value').toISOString()).toEqual(now);
    expect(component.find(Datetime).at(1).prop('value').toISOString()).toEqual(now);
    expect(component.find(BootstrapFormInput).filter({ name: 'name' }).prop('value')).toEqual('myName');
    expect(component.find(BootstrapFormInput).filter({ name: 'domain' }).prop('value')).toEqual('myDomain');
    expect(component.find(TimezoneSelect).prop('value')).toEqual('UTC');
    expect(component.find(BootstrapFormCheckbox).filter({ name: 'accepting_proposals', value: 'true' }).prop('checked')).toBeTruthy();
    expect(component.find(BootstrapFormCheckbox).filter({ name: 'registrations_frozen', value: 'true' }).prop('checked')).toBeTruthy();
    expect(component.find(BootstrapFormCheckbox).filter({ name: 'show_schedule', value: 'gms' }).prop('checked')).toBeTruthy();
    expect(component.find(BootstrapFormInput).filter({ name: 'maximum_tickets' }).prop('value')).toEqual('100');

    const maximumEventSignups = component.find(ScheduledValueEditor);
    expect(maximumEventSignups.find(Datetime).at(1).prop('value').toISOString()).toEqual(now);
    expect(maximumEventSignups.find(Datetime).at(2).prop('value').toISOString()).toEqual(now);
    expect(maximumEventSignups.find('select').at(0).prop('value')).toEqual('not_yet');
    expect(maximumEventSignups.find('select').at(1).prop('value')).toEqual('unlimited');
  });

  test('mutating form fields', () => {
    const component = renderConventionForm();
    component.find(BootstrapFormCheckbox).filter({ name: 'registrations_frozen', value: 'true' })
      .find('input').simulate('change', { target: { name: 'registrations_frozen', value: 'true' } });
    expect(component.instance().state.convention.registrations_frozen).toBeTruthy();
  });

  test('onClickSave', () => {
    const saveConvention = jest.fn();
    const component = renderConventionForm({ saveConvention });
    component.find('.btn-primary').simulate('click');
    expect(saveConvention.mock.calls[0][0]).toEqual(defaultInitialConvention);
  });
});

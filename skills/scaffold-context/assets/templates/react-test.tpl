import { render, screen } from '@testing-library/react';
import App from '../App';

it('renders the project shell', () => {
  render(<App />);
  expect(screen.getByRole('heading', { name: '{{ project_name }}' })).toBeInTheDocument();
});

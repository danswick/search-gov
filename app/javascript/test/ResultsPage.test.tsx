import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import * as React from 'react';
import ResultsPage from '../components/ResultsPage';

describe('ResultsPage', () => {
  it('shows a message when there are no results', () => {
    render(<ResultsPage params="foo" results={[]} />);
    const message = screen.getByText(/Please enter a search term in the box above./i);
    expect(message).toBeInTheDocument();
  });

  it('renders all relevant links', () => {
    render(<ResultsPage params="foo" results={[]} />);
    const privacyPolicy = screen.getAllByText(/Privacy policy/i)[0];
    const updates = screen.getAllByText(/Latest updates/i)[0];
    const everything = screen.getByText(/Everything/i);
    const news = screen.getByText(/News/i);
    const images = screen.getByText(/Images/i);
    const videos = screen.getByText(/Videos/i);
    expect(privacyPolicy).toBeInTheDocument();
    expect(updates).toBeInTheDocument();
    expect(everything).toBeInTheDocument();
    expect(news).toBeInTheDocument();
    expect(images).toBeInTheDocument();
    expect(videos).toBeInTheDocument();
  });

  it('renders search results', () => {
    const results = [{ 'title': 'test result 1', 'unescapedUrl': 'https://www.search.gov', 'content': 'result body' }];
    render(<ResultsPage params="foo" results={results} />);
    const resultTitle = screen.getByText(/test result 1/i);
    const resultUrl = screen.getByText(/https\:\/\/www.search.gov/i);
    const resultBody = screen.getByText(/result body/i);
    expect(resultTitle).toBeInTheDocument();
    expect(resultUrl).toBeInTheDocument();
    expect(resultBody).toBeInTheDocument();
  });
});
